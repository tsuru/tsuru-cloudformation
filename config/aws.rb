require 'fog'
require 'json'

module AWS
  AWS_ACCESS_KEY_ID = ENV['AWS_ACCESS_KEY_ID'] || nil
  AWS_SECRET_ACCESS_KEY = ENV['AWS_SECRET_ACCESS_KEY'] || nil
  raise "AWS_ACCESS_KEY_ID or/and AWS_SECRET_ACCESS_KEY not found." if AWS_ACCESS_KEY_ID.nil? || AWS_SECRET_ACCESS_KEY.nil?
  @@conn = Fog::Compute.new(:provider => "AWS", :aws_access_key_id => AWS_ACCESS_KEY_ID, :aws_secret_access_key => AWS_SECRET_ACCESS_KEY)

  def self.hosts_for(group)
    @hosts = Array.new
    @@conn.servers.sort_by(&:created_at).each do |server|
      @hosts << server.private_ip_address if server.groups.include?(group.to_s) && server.state == "running"
    end
    @hosts.uniq
  end

end
