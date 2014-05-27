directory "/home/vagrant/bin"

skip_tables = node[:ev][:project][:database][:skip_tables].map { |table|
  "--ignore-table=#{table}"
}.join(' ')

template "/home/vagrant/bin/rebuild.sh" do
  source "rebuild.sh.erb" 
  owner "vagrant"
  group "vagrant"
  mode 0700
  variables({
    :skip_tables => skip_tables,
    :project_name => node[:ev][:project][:name]
  })
end
