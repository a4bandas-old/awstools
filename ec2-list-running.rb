#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'fog'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [-c credential] [role]"

  options[:credential] = :kedin
  opts.on( '-c', '--credential CRED', 'Use specific credentials from ~/.fog' ) do |cred|
    options[:credential] = cred.to_sym
  end

end
optparse.parse!

role = ARGV[0] || :all

Fog.credential = options[:credential]
ec2 = Fog::AWS::Compute.new

servers = ec2.servers.all

puts "# Servers for #{options[:credential]}"

servers.each do |server|
  if role == :all
    #puts server.inspect
    puts "#{server.tags['role']}: #{server.ip_address} - #{server.private_ip_address} (#{server.state})"
  else
    if server.state == 'running' && server.tags['role'].match(/^#{role}/)
      puts "#{server.private_ip_address} #{server.tags['role']}"
    end
  end
end

