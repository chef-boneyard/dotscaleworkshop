include_recipe "chef-server-cluster"

chef_secrets      = Hash[data_bag_item('secrets', "private-chef-secrets-#{node.chef_environment}")['data'].sort]
reporting_secrets = Hash[data_bag_item('secrets', "opscode-reporting-secrets-#{node.chef_environment}")['data'].sort]

# It's easier to deal with a hash rather than a data bag item, since
# we're not going to need any of the methods, we just need raw data.
chef_server_config = data_bag_item('chef_server', 'topology').to_hash
chef_server_config.delete('id')
chef_server_config['rabbitmq'] = { 'node_ip_address' => '0.0.0.0' }
node.default['chef-server-cluster'].merge!(chef_server_config)

file '/etc/opscode/private-chef-secrets.json' do
  content JSON.pretty_generate(chef_secrets)
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]'
  sensitive true
end

file '/etc/opscode-reporting/opscode-reporting-secrets.json' do
  content JSON.pretty_generate(reporting_secrets)
  notifies :reconfigure, 'chef_server_ingredient[opscode-reporting]'
  sensitive true
end

template '/etc/opscode/chef-server.rb' do
  source 'chef-server.rb.erb'
  variables :chef_server_config => node['chef-server-cluster']
  notifies :reconfigure, 'chef_server_ingredient[chef-server-core]'
  notifies :run, 'execute[chef-server-ctl restart rabbitmq]'
end

# This is to work around an issue where rabbitmq doesn't always listen
# on 0.0.0.0 after `reconfigure` despite the configuration above.
execute 'chef-server-ctl restart rabbitmq' do
  action :nothing
end

# These two resources set permissions on the files to make them
# readable as a workaround for
# https://github.com/opscode/chef-provisioning/issues/174
file '/etc/opscode-analytics/actions-source.json' do
  mode 00644
  subscribes :create, 'chef_server_ingredient[chef-server-core]', :immediately
end

file'/etc/opscode-analytics/webui_priv.pem' do
  mode 00644
  subscribes :create, 'chef_server_ingredient[chef-server-core]', :immediately
end

file '/etc/opscode/pivotal.pem' do
  mode 00644
  # without this guard, we create an empty file, causing bootstrap to
  # not actually work, as it checks the presence of this file.
  only_if { ::File.exists?('/etc/opscode/pivotal.pem') }
  subscribes :create, 'chef_server_ingredient[chef-server-core]', :immediately
end

chef_server_ingredient 'opscode-manage' do
  notifies :reconfigure, 'chef_server_ingredient[opscode-manage]'
end

directory '/etc/opscode-manage'

chef_server_ingredient 'opscode-reporting' do
  notifies :reconfigure, 'chef_server_ingredient[opscode-reporting]'
end

execute "create admin user" do
  command "chef-server-ctl user-create analytics Analytics Workshop dont@send.email workshop --filename /tmp/analytics.pem"
  notifies :run, 'execute[create analytics org]'
  creates "/tmp/analytics.pem"
  action :nothing
end

execute "create analytics org" do
  command 'chef-server-ctl org-create analytics "Analytics Workshop" --association_user analytics --filename /tmp/analytics-validator.pem'
  action :nothing
  creates "/tmp/analytics-validator.pem"
end
