include_recipe "apt"
include_recipe "openssl"
include_recipe "mysql::server"
include_recipe "database::mysql"
include_recipe "apache2"
include_recipe "apache2::mod_php5"

# using apt
package "php5-memcache"

# using apt
package "php5-mysql"

# using apt
package "php5-gd"

gem_package "compass"

mysql_connection_info = {
  :host => "localhost",
  :username => 'root',
  :password => node['mysql']['server_root_password']
}

# Creates the project mysql database
mysql_database "#{node['ev']['project']['name']}" do
  connection mysql_connection_info
  action :create
end

# Creates the project mysql user and grants access
mysql_database_user "#{node['ev']['project']['name']}" do
  connection mysql_connection_info
  password "#{node['ev']['project']['name']}"
  database_name "#{node['ev']['project']['name']}"
  host 'localhost'
  privileges [:all]
  action :create
  action :grant
end

web_app "#{node['ev']['project']['name']}" do
  server_name "#{node['ev']['project']['name']}.local.elephantventures.com"
  server_aliases ["#{node['ev']['project']['name']}.local.elephantventures.com"]
  docroot "/home/vagrant/workspace/#{node['ev']['project']['name']}/web"
  cgi_bin_dir "/home/vagrant/workspace/#{node['ev']['project']['name']}/cgi-bin"
  allow_override "All"
end


include_recipe "ev::drupal_prep"
include_recipe "ev::drupal_install"
