package 'unzip'
package 'libffi-dev'
package 'zlib1g-dev'
package 'python-dev'
package 'rake'
package 'python-mysqldb'

user 'appuser' do
  home '/opt/appuser'
  shell '/bin/bash'
  manage_home true
end

directory "#{node[:webapp][:base_dir]}/webapp-master" do
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
  command "cd #{node[:webapp][:base_dir]}/webapp-master; python setup.py install"
end

template "#{node[:webapp][:base_dir]}/webapp-master/conf/webapp.cfg" do
  source "webapp.cfg.template"
  variables({
    :db_conf => node[:webapp][:db_conf]
  })
end

execute 'Run webapp' do
  command "cd #{node[:webapp][:base_dir]}/webapp-master; python webapp.py &> log/webapp.log &"
end

include_recipe 'webapp::tests'
