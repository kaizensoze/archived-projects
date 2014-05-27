directory '/home/vagrant/.ssh' do
  mode 0700
end

cookbook_file '/home/vagrant/.ssh/id_rsa' do
  source 'id_rsa'
  mode 0600
  owner 'vagrant'
  group 'vagrant'
end
