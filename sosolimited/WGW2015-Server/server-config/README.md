# Server setup

## setup algo
[secure linode](#secure-linode)  
[switch to static ip](#switch-to-static-ip)

    sudo apt-get update
    sudo apt-get install -y vim curl git
    sudo apt-get install build-essential

    curl -sL https://deb.nodesource.com/setup | sudo bash -
    sudo apt-get install -y nodejs
    sudo npm install npm -g
    sudo npm install supervisor -g

    sudo apt-get -y install redis-server
    sudo vim /etc/sysctl.conf -> add `vm.overcommit_memory = 1`
    sudo sysctl -p


[clone WGW2015-Server repo](#clone-repo)  
[performance tune](#performance-tuning)  
[setup monitoring](#monitoring)  
[setup redis db archiving cronjob](#redis-archiving-cronjob)  

## setup api
[secure linode](#secure-linode)  
[switch to static ip](#switch-to-static-ip)

    sudo apt-get update
    sudo apt-get install -y vim curl git
    sudo apt-get install build-essential

    curl -sL https://deb.nodesource.com/setup | sudo bash -
    sudo apt-get install -y nodejs
    sudo npm install npm -g
    sudo npm install supervisor -g

    sudo apt-get -y install redis-server
    sudo vim /etc/sysctl.conf -> add `vm.overcommit_memory = 1`
    sudo sysctl -p

[clone WGW2015-Server repo](#clone-repo)  
[performance tune](#performance-tuning)  
[setup monitoring](#monitoring)  

## setup load balancer
[secure linode](#secure-linode)  
[switch to static ip](#switch-to-static-ip)

    sudo apt-get update
    sudo apt-get install -y vim curl git
    sudo apt-get install build-essential
    sudo apt-get install nginx

    sudo cp nginx/common.conf /etc/nginx
    sudo cp nginx/nginx.conf /etc/nginx
    sudo cp nginx/proxy_params /etc/nginx
    sudo cp nginx/wgwapi.com /etc/nginx/sites-available
    sudo ln -vs /etc/nginx/sites-available/wgwapi.com /etc/nginx/sites-enabled/wgwapi.com
    sudo rm /etc/nginx/sites-available/default
    sudo rm /etc/nginx/sites-enabled/default
    sudo nginx -s reload

[performance tune](#performance-tuning)  
[setup monitoring](#monitoring)  

## secure linode
Create and boot linode server via linode admin interface.

`ssh root@<linode_ip>`

    # add soso user with root permissions
    adduser soso
    usermod -a -G sudo soso

    # switch to soso user
    su - soso

    # disable root login
    sudo vim /etc/ssh/sshd_config
    PermitRootLogin no

    sudo service ssh restart

    # iptables
    sudo vim /etc/iptables.firewall.rules
    (see linux/iptables.firewall.rules)

    sudo iptables-restore < /etc/iptables.firewall.rules

    # have iptable rules load on reboot
    sudo vim /etc/network/if-pre-up.d/firewall
    #!/bin/sh
    /sbin/iptables-restore < /etc/iptables.firewall.rules

    sudo chmod +x /etc/network/if-pre-up.d/firewall

    # fail2ban
    sudo apt-get install -y fail2ban

## switch to static ip

In remote access tab for linode, click Add a Private IP.

    sudo vim /etc/hostname
    <linode-name>

    sudo hostname -F /etc/hostname

    sudo vim /etc/hosts
    127.0.0.1       localhost
    127.0.1.1       ubuntu
    <private-ip>   <linode-name>

    sudo vim /etc/network/interfaces
    (see linux/interfaces)

    sudo ifdown -a
    sudo ifup -a

Ping the gateway to verify everything's ok.

## clone repo
To access the github repo from the linode, you'll want to edit the ssh config file on
the machine you're connecting to the linode from:
   
    vim ~/.ssh/config
    Host <host_label (whatever you want to call it)>
      HostName <linode_ip>
      User soso
      ForwardAgent yes

Then ssh into the linode.

    # clone repo
    git clone git@github.com:sosolimited/WGW2015-Server.git

## open ports summary
<pre><code>dev
    80
    443
    3000
    8080 (m/monit)
algo
    80
    443
    6379 <- 192.168.133.101 (redis open to wgw-prod-api1 for replication)
    2812
api
    80
    443
    3000 <- 192.168.150.115 (node.js open to lb)
    2812
lb
    80
    443
    2812
</code></pre>

## redis archiving cronjob
    cp cron/redis-backup.sh ~
    sudo vim /etc/crontab
    (see cron/crontab)

## monitoring
Install postfix mail server (see: https://www.digitalocean.com/community/tutorials/how-to-install-and-setup-postfix-on-ubuntu-14-04)

Install monit:

    sudo apt-get install monit

And configure:

    sudo vim /etc/monit/monitrc
    (see monit/monitrc file)

`sudo service monit restart`

Open up port 2812 on each server you install monit on.

M/Monit allows you to aggregate and view all monitored host info in one place. Install it on dev:

    wget http://mmonit.com/dist/mmonit-3.4-linux-x64.tar.gz  (see http://mmonit.com/download/ for latest version)
    tar zxvf mmonit-3.4-linux-x64.tar.gz
    rm mmonit-3.4-linux-x64.tar.gz
    cd mmonit-3.4
    ./bin/mmonit

Open up port 8080 on dev for m/monit and then go to **http://104.237.128.23:8080** to view the m/monit console. Default login is admin:swordfish.
Once logged in, remove the monit and admin users and create a user with `soso:<password>` credentials. On the status page, you should
see a list of servers with monit installed that are now communicating with the m/monit service.

## performance tuning
<pre><code># increase network limits
sudo vim /etc/sysctl.conf
fs.file-max = 65535
net.ipv4.ip_local_port_range = 1024 65000
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15
net.core.netdev_max_backlog = 4096
net.core.rmem_max = 16777216
net.core.somaxconn = 4096
net.core.wmem_max = 16777216
net.ipv4.tcp_max_syn_backlog = 20480
net.ipv4.tcp_max_tw_buckets = 400000
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_wmem = 4096 65536 16777216
vm.min_free_kbytes = 65536

# load new sysctl settings
sudo sysctl -p

# increase file descriptor limit
sudo vim /etc/security/limits.conf
* hard nofile 65535
* soft nofile 65535

verify with ulimit -n (might need to logout and back in first)
</code></pre>

## load testing

### Test a single url
    siege -c200 -b -t3M "http://localhost/game/tweets?time=min"

### Test multiple urls
More realistic simulation of randomly hitting a url from a list (see siege/urls.txt)

    siege -c200 -b -t3M -i -f urls.txt