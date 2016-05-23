package 'unzip'
package 'libffi-dev' do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'libffi-devel'
  when 'ubuntu', 'debian'
    package_name 'libffi-dev'
  end
end
package 'zlib' do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'zlib-devel'
  when 'ubuntu', 'debian'
    package_name 'zlib1g-dev'
  end
end
package 'python-dev' do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'python-devel'
  when 'ubuntu', 'debian'
    package_name 'python-dev'
  end
end
package 'ruby' do
  case node[:platform]
  when 'redhat', 'centos'
    package_name 'ruby'
  when 'ubuntu', 'debian'
    package_name 'rake'
  end
end



user 'appuser' do
  home '/opt/appuser'
  shell '/bin/bash'
  manage_home true
end

directory "#{node[:webapp][:base_dir]}" do
  owner 'appuser'
  group 'appuser'
  mode '0750'
  action :create
end

remote_file "/tmp/webapp_master.zip" do
  source node[:webapp][:zip_url]
  action :create
end

execute 'Unzip snapshot of webapp' do
  command "unzip -o /tmp/webapp_master.zip -d #{node[:webapp][:base_dir]}"
  user  'appuser'
  group 'appuser'
end

execute 'Install webapp dependencies' do
  command "python #{node[:webapp][:base_dir]}/webapp-master/setup.py install"
end

execute 'Run webapp' do
  command "python #{node[:webapp][:base_dir]}/webapp-master/webapp.py &> #{node[:webapp][:base_dir]}/webapp.log &"
end

include_recipe 'webapp::tests'
