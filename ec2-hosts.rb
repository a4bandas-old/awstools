#!/usr/bin/env ruby

require 'rubygems'
require 'fog'

Fog.credential = :otlive
HOSTS_FILE = '/etc/hosts'
AUTO_GENERATED = 'auto-generated'

def load_hosts(filename)
  lines = []
  File.open(filename, "r") do |infile|
    lines = infile.readlines
  end
  lines
end

def save_hosts(filename, lines)
  File.open(filename, "w") do |outfile|
    lines.each do |line|
      outfile.write line
    end
  end
end

def generate_hosts
  ec2 = Fog::AWS::Compute.new
  generated_hosts = []
  ec2.servers.all.each do |server|
    if server.ip_address
      generated_hosts << "#{server.ip_address} #{server.tags['role']}.public  # #{AUTO_GENERATED}\n"
    end
    if server.private_ip_address
      generated_hosts << "#{server.private_ip_address} #{server.tags['role']}.private  # #{AUTO_GENERATED}\n"
    end
  end
  generated_hosts
end

original_hosts = load_hosts(HOSTS_FILE)

stripped_hosts = original_hosts.reject{ |l| l.match(AUTO_GENERATED) }

new_hosts = stripped_hosts + generate_hosts

if new_hosts != original_hosts
  save_hosts(HOSTS_FILE, new_hosts)
end

