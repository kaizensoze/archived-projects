app_name = node[:ev][:project][:name]
deploy_dir = "/home/vagrant/workspace/#{node['ev']['project']['name']}/web"
db_host = "localhost"
db_password = node[:ev][:project][:mysql][:password]
db_user = node[:ev][:project][:mysql][:username]
db_name = node[:ev][:project][:mysql][:db_name]
profile_name = node[:ev][:project][:profile_name]

template "#{deploy_dir}/sites/default/settings.php" do
  source "settings.php.erb"
  owner "www-data"
  group "www-data"
  mode 0777
  variables({
    :db_host => db_host
  })
end

execute "site-install" do
  command "/usr/bin/drush site-install #{profile_name}"\
  " install_configure_form.update_status_module='array(FALSE,FALSE)'"\
  " --db-url=mysql://#{db_user}:#{db_password}@#{db_host}/#{db_name}"\
  " --site-name=#{app_name}"\
  " --account-name=admin --account-pass=admin -y "
  cwd "#{deploy_dir}"
end
