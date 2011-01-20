#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'fog'

options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [-c credential] [action]\n    Valid actions: status, add-frontend, remove-frontend"

  options[:credential] = :otlive
  opts.on( '-c', '--credential CRED', 'Use specific credentials from ~/.fog' ) do |cred|
    options[:credential] = cred.to_sym
  end

end
optparse.parse!

action = ARGV[0] || 'status'

if action != 'status' && action != 'add-frontend' && action != 'remove-frontend'
  puts optparse
  exit
end

Fog.credential = options[:credential]
ec2 = Fog::AWS::Compute.new

servers = ec2.servers.all.sort{|a,b| a.tags['role'] <=> b.tags['role'] }

case action
when 'status'
  puts "# Servers for #{options[:credential]}"
  servers.each do |server|
    puts "#{server.tags['role']}, public: #{server.ip_address}, private: #{server.private_ip_address} (#{server.state})"
  end
when 'add-frontend'
  servers.each do |server|
    if server.tags['role'].match(/^frontend\d+$/) && server.state == 'stopped'
      puts "Starting '#{server.tags['role']}'"
      server.start
      break
    end
  end
when 'remove-frontend'
  servers.reverse.each do |server|
    if server.tags['role'].match(/^frontend\d+$/) && server.state == 'running'
      next if server.tags['role'].match(/^frontend[12]$/) 
      puts "Stopping '#{server.tags['role']}'"
      server.stop
      break
    end
  end
end

