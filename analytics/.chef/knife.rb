current_dir = File.dirname(__FILE__)

log_level                :info
log_location             STDOUT
node_name                "analytics"
client_key               "#{current_dir}/analytics.pem"
validation_client_name   "analytics-validator"
validation_key           "#{current_dir}/analytics-validator.pem"
chef_server_url          "https://192.168.56.100/organizations/analytics"
analytics_server_url     "https://192.168.56.101/organizations/analytics"
syntax_check_cache_path  "#{current_dir}/syntax_check_cache"
ssl_verify_mode :verify_none
cookbook_path           "#{current_dir}/../cookbooks"
