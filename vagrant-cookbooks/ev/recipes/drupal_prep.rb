#
# Author :: Brandon Schlueter <brandon@elephantventures.com>
# Cookbook name :: ev
#
# Depends:
#   *ev.php.pear_channels
#   *ev.php.drush_package (the name of the drush package which will be installed with pear)
#   *ev.php.drush_package_name (
# 

package "php-pear"
  

Array(node[:ev][:php][:pear_channels]).each do |channel|
  execute "/usr/bin/pear channel-discover #{channel}" do
    not_if "/usr/bin/pear channel-info #{channel}"
  end
  execute "/usr/bin/pear install Console_Table" do
  end
end

# FUTURE FEATURE use/create a pear resource
execute "/usr/bin/pear install #{node[:ev][:php][:drush_package]}" do
  not_if "/usr/bin/pear list #{node[:ev][:php][:drush_package_name]}"
end
