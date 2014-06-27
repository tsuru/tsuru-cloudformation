# Tsuru API Template
load 'config/aws.rb'
require 'yaml'
cloud = YAML.load_file(File.expand_path('cloud.yaml'))['cloud']

domain_name = cloud['domain_name']
app_name = cloud['app_name']
ami = cloud['aws_ami']
mongo_hosts = AWS.hosts_for(cloud['mongo_security_group'])
mongo_url = mongo_hosts.empty? ? 'localhost:27017' : mongo_hosts.join(':27017') + ':27017'
redis_host = AWS.hosts_for(cloud['redis_security_group'])
redis_host = redis_host.empty? ? 'localhost:6379' : redis_host + ':6379'
tsuru_ssh_key = cloud['keys']['tsuru_ssh_key']
tsuru_ssh_bucket =  cloud['keys']['tsuru_ssh_bucket']
gandalf_registry_device = cloud['gandalf_registry_device']
vpc_cidr = cloud['vpc_cidr']

template "tsuru-vpc.json" do
  source "tsuru-vpc.json.erb"
  variables(
    :vpc_cidr => vpc_cidr,
    :vpc_subnets => { :router => cloud['tsuru-router']['vpc_network'],
                      :api => cloud['tsuru-api']['vpc_network'],
                      :registryGandalf => cloud['tsuru-registry-gandalf']['vpc_network'],
                      :docker => cloud['tsuru-docker']['vpc_network']
    }
  )
end

template "tsuru-groups.json" do
  source "tsuru-groups.json.erb"
  variables(
    :mongo_security_group_id => AWS.group_aws_id('mongo-tsuru-private')
  )
end

template "MongoDB_ReplicaSetMemberUbuntu.template" do
  source "MongoDB_ReplicaSetMemberUbuntu.template.erb"
  variables(
    :ami => ami
  )
end

template "MongoDB_ReplicaSetStackUbuntu.json" do
  source "MongoDB_ReplicaSetStackUbuntu.json.erb"
  variables(
    :ami => ami
  )
end

template "tsuru-api.json" do
  source "tsuru-api.json.erb"
  variables(
    :domain_name => domain_name,
    :app => "tsuru-api",
    :ami => ami,
    :instance_type => cloud['tsuru-api']['instance_type'],
    :security_group => "tsuru-api",
    :min_instances => cloud['tsuru-api']['min_instances'],
    :max_instances => cloud['tsuru-api']['max_instances'],
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
                       :tsuru_docker_container_public_key => '/var/lib/tsuru/' + tsuru_ssh_key + '.pub'
                      }
  )
end

template "tsuru-docker.json" do
  source "tsuru-docker.json.erb"
  variables(
    :domain_name => domain_name,
    :app => "tsuru-docker",
    :ami => ami,
    :instance_type => cloud['tsuru-docker']['instance_type'],
    :min_instances => cloud['tsuru-docker']['min_instances'],
    :max_instances => cloud['tsuru-docker']['max_instances'],
    :security_group => "tsuru-docker",
    :tsuru_ssh_keys_bucket => tsuru_ssh_bucket,
    :tsuru_ssh_key => tsuru_ssh_key,
    :puppet_class => {
      :tsuru_ssh_agent => 'true',
      :tsuru_ssh_agent_private_key => '/var/lib/tsuru/' + tsuru_ssh_key
    }
  )
end

template "tsuru-registry-gandalf.json" do
  source "tsuru-registry-gandalf.json.erb"
  variables(
    :domain_name => domain_name,
    :app => "tsuru-registry-gandalf",
    :ami => ami,
    :instance_type => cloud['tsuru-registry-gandalf']['instance_type'],
    :security_group => "tsuru-registry-gandalf",
    :tsuru_ssh_keys_bucket => tsuru_ssh_bucket,
    :tsuru_ssh_key => tsuru_ssh_key,
    :mongo_security_group_id => AWS.group_aws_id('mongo-tsuru-private'),
    :puppet_class => {
      :tsuru_gandalf => {
        :gandalf_host => 'http://git.' + domain_name,
        :gandalf_db_url => mongo_url,
        :tsuru_api_host => 'api.' + domain_name,
        :tsuru_api_token => 'xxx'
      },
      :tsuru_registry=> {
        :registry_ipbind_port => '0.0.0.0:80'
      }
    }
  )
end

# Update Policy
template "update-delete-policy.json" do
  source "update-delete-policy.erb"
end
