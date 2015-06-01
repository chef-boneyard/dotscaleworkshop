node.default['chef-server-cluster']['role'] = 'analytics'
analytics_fqdn = data_bag_item('chef_server', 'topology')['analytics_fqdn'] || node['ec2']['public_hostname']

# We define these here instead of including the default recipe because
# analytics doesn't actually need chef-server-core.
directory '/etc/opscode' do
  recursive true
end

directory '/etc/opscode-analytics' do
  recursive true
end

file '/etc/opscode-analytics/opscode-analytics.rb' do
  content "topology 'standalone'\nanalytics_fqdn '#{analytics_fqdn}'"
end

chef_server_ingredient 'opscode-analytics'
