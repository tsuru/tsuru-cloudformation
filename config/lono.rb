# Tsuru API Template
load 'config/aws.rb'

template "tsuru-api.json" do
  mongo_hosts = AWS.hosts_for('mongo-tsuru-private')
  mongo_url = mongo_hosts.empty? ? 'localhost:27017' : mongo_hosts.join(':27017') + ':27017' 
  source "tsuru-api.json.erb"
  variables(
    :app => "tsuru-api",
    :ami => "ami-0568456c",
    :instance_type => "m1.medium",
    :security_group => "tsuru-api",
    :puppet_class => { :tsuru_app_domain => 'tsuru.cloud.io',
                       :tsuru_api_server_url => 'api.tsuru.cloud.io',
                       :tsuru_git_url => 'http://git.tsuru.cloud.io',
                       :tsuru_git_rw_host => 'tsuru.git.cloud.io',
                       :tsuru_git_ro_host => 'tsuru.git.cloud.io',
                       :tsuru_redis_server => 'localhost',
                       :tsuru_mongodb_url  => mongo_url,
                       :tsuru_registry_server => 'registry.tsuru.cloud.io',
                       :tsuru_docker_servers_urls => ['docker1', 'docker2', 'docker3'] }
  )
end

# Update Policy
template "update-delete-policy.json" do
  source "update-delete-policy.erb"
end
