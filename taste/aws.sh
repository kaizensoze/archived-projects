
# Requirements: jq, gsed

# update caribou
CARIBOU=50.16.202.217
ssh web@$CARIBOU 'source /usr/local/bin/virtualenvwrapper.sh && workon www.tastesavant.com && git pull; pip install -r etc/requirements.txt && export DJANGO_SETTINGS_MODULE=settings.production_base && ./manage.py migrate && ./manage.py collectstatic --noinput && sudo supervisorctl restart all'

# start and update elk
ELK=i-911bfbf0

aws ec2 describe-instances --instance-ids $ELK
aws ec2 start-instances --instance-ids $ELK
PUBLIC_DNS_NAME=$(aws ec2 describe-instances --instance-ids $ELK | jq -r '.Reservations[0] | .Instances[0] | .PublicDnsName')

ssh web@$PUBLIC_DNS_NAME 'source /usr/local/bin/virtualenvwrapper.sh && workon www.tastesavant.com && git pull'

function new_ami_name() {
    aws ec2 describe-images --filters Name=owner-id,Values=938858887109 |
    jq -r '.Images[] | .Name' |
    sort -n -k 3 -t - |
    tail -n 1 |
    gsed -re 's/taste-savant-([0-9]+)/echo taste-savant-$((\1+1))/e'
}
NEW_AMI_NAME=$(new_ami_name)
echo "NEW_AMI_NAME: $NEW_AMI_NAME"

NEW_AMI=$(aws ec2 create-image --name $NEW_AMI_NAME --instance-id $ELK | jq -r '.ImageId')
echo "NEW_AMI: $NEW_AMI"

function new_lc_name() {
    # --max-records high enough to show all the launch configs.
    aws autoscaling describe-launch-configurations --max-items 200 |
    jq -r '.LaunchConfigurations[] | .LaunchConfigurationName' |
    sort -n -k 2 -t c |
    tail -n 1 |
    gsed -re 's/lc([0-9]+)/echo lc$((\1+1))/e'
}
NEW_LC_NAME=$(new_lc_name)
echo "NEW_LC_NAME: $NEW_LC_NAME"

# create new launch configuration
aws autoscaling create-launch-configuration --launch-configuration-name $NEW_LC_NAME --image-id $NEW_AMI --instance-type m1.small

# update autoscaling group with new launch configuration
aws autoscaling update-auto-scaling-group --auto-scaling-group-name asg --launch-configuration-name $NEW_LC_NAME

# refresh autoscaling instances
AUTOSCALING_INSTANCES=( $(aws autoscaling describe-auto-scaling-instances | jq -r '.AutoScalingInstances[] | .InstanceId') )

for INSTANCE_ID in "${AUTOSCALING_INSTANCES[@]}"
do
    aws autoscaling terminate-instance-in-auto-scaling-group --instance-id $INSTANCE_ID --no-should-decrement-desired-capacity
done

# NOTE: It'll take some time for the current instances to terminate and the new ones to pop up. (Don't panic!)
