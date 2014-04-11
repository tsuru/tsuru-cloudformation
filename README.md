#Tsuru AWS Cloud Formation

Lono template files for Tsuru Cloud using Amazon Cloud Formation

Lono is a ruby gem that generate all JSON files used by Tsuru to create AWS
Cloud Formation stacks. The result will be a fully functional Tsuru environment
with auto-scaling.

Instructions:

- Run bundle install
- Configure cloud.yaml
- Create an instance (or instances) with mongodb (using replicaset or not) and
  redis server on security groups defined on cloud.yaml.
- Configure [Amazon Route 53](http://docs.aws.amazon.com/Route53/latest/DeveloperGuide/creating-migrating.html)
  to receive your domain or subdomain
- Generate ssh-keys, using ssh-keygen, and put both private and
  public keys on bucket defined on cloud.yaml.
- Run 'lono generate'. All output cloud formation file will be available on
  'output' dir. You should create tsuru-docker stack first.
