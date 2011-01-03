#!/usr/bin/env ruby

require 'rubygems'
require 'fog'

Fog.credential = :otlive

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
      generated_hosts << "#{server.ip_address} #{server.tags['role']}.public  # auto-generated\n"
    end
    if server.private_ip_address
      generated_hosts << "#{server.private_ip_address} #{server.tags['role']}.private  # auto-generated\n"
    end
  end
  generated_hosts
end

original_hosts = load_hosts('hosts')

stripped_hosts = original_hosts.reject{ |l| l.match('auto-generated') }

new_hosts = stripped_hosts + generate_hosts

if new_hosts != original_hosts
  save_hosts('hosts', new_hosts)
end

