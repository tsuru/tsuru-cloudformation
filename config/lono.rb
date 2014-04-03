# Tsuru API Template
load 'config/aws.rb'

domain_name = 'labs.tsuru.io'
app_name = 'cloud.labs.tsuru.io'
mongo_hosts = AWS.hosts_for('mongo-tsuru-private')
mongo_url = mongo_hosts.empty? ? 'localhost:27017' : mongo_hosts.join(':27017') + ':27017'
redis_host = AWS.hosts_for('redis-tsuru-private')
redis_host = redis_host.empty? ? 'localhost:6379' : redis_host + ':6379'
tsuru_ssh_key = 'id_rsa_tsuru_labs'
tsuru_ssh_bucket = "tsuru-labs-ssh-keys"

template "tsuru-api.json" do
  source "tsuru-api.json.erb"
  variables(
    :domain_name => domain_name,
    :app => "tsuru-api",
    :ami => "ami-0568456c",
    :instance_type => "m1.small",
    :security_group => "tsuru-api",
    :tsuru_ssh_keys_bucket => tsuru_ssh_bucket,
    :tsuru_ssh_key => tsuru_ssh_key,
    :mongo_security_group_id => AWS.group_aws_id('mongo-tsuru-private'),
    :puppet_class => { :tsuru_app_domain => app_name,
                       :tsuru_api_server_url => 'api.' + domain_name,
                       :tsuru_git_url => 'http://git.' + domain_name,
                       :tsuru_git_rw_host => 'git.' + domain_name,
                       :tsuru_git_ro_host => 'git.' + domain_name,
                       :tsuru_redis_server => redis_host,
                       :tsuru_mongodb_url  => mongo_url,
                       :tsuru_registry_server => 'registry.' + domain_name,
                       :tsuru_docker_servers_urls => ['docker1', 'docker2', 'docker3'],
                       :tsuru_docker_container_public_key => '/var/lib/tsuru/' + tsuru_ssh_key + '.pub'
                      }
  )
end

template "tsuru-docker.json" do
  source "tsuru-docker.json.erb"
  variables(
    :domain_name => domain_name,
    :app => "tsuru-docker",
    :ami => "ami-0568456c",
    :instance_type => "m1.small",
    :security_group => "tsuru-docker",
    :tsuru_ssh_keys_bucket => tsuru_ssh_bucket,
    :tsuru_ssh_key => tsuru_ssh_key,
    :puppet_class => {
      :tsuru_ssh_agent => 'true',
      :tsuru_ssh_agent_private_key => '/var/lib/tsuru/' + tsuru_ssh_key
    }
  )
end

# Update Policy
template "update-delete-policy.json" do
  source "update-delete-policy.erb"
end
