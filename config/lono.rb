# Tsuru API Template
load 'config/aws.rb'

domain_name = 'labs.tsuru.io'
mongo_hosts = AWS.hosts_for('mongo-tsuru-private')
mongo_url = mongo_hosts.empty? ? 'localhost:27017' : mongo_hosts.join(':27017') + ':27017'

template "tsuru-api.json" do
  source "tsuru-api.json.erb"
  variables(
    :domain_name => domain_name,
    :app => "tsuru-api",
    :ami => "ami-0568456c",
    :instance_type => "m1.medium",
    :security_group => "tsuru-api",
    :puppet_class => { :tsuru_app_domain => 'tsuru.cloud.io',
                       :tsuru_api_server_url => 'api.' + domain_name,
                       :tsuru_git_url => 'http://git.' + domain_name,
                       :tsuru_git_rw_host => 'git' + domain_name,
                       :tsuru_git_ro_host => 'git' + domain_name,
                       :tsuru_redis_server => 'localhost',
                       :tsuru_mongodb_url  => mongo_url,
                       :tsuru_registry_server => 'registry' + domain_name,
                       :tsuru_docker_servers_urls => ['docker1', 'docker2', 'docker3'] }
  )
end

# Update Policy
template "update-delete-policy.json" do
  source "update-delete-policy.erb"
end
