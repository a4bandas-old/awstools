#!/usr/bin/env ruby

require 'rubygems'
require 'optparse'
require 'fog'

action = 'status'
options = {}
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [-c credential] [--force-run NUM] [action]\n    Valid actions: status, add-frontend, remove-frontend"

  options[:credential] = :otlive
  opts.on( '-c', '--credential CRED', 'Use specific credentials from ~/.fog' ) do |cred|
    options[:credential] = cred.to_sym
  end
  opts.on( '--force-run NUM', 'Start or stop frontends to run NUM servers') do |num|
    options[:force_num] = num.to_i
    action = 'force-run'
    if options[:force_num] < 2
      puts "force-run must be >= 2"
      exit
    end
  end

end
optparse.parse!

action = ARGV[0] || action
unless %w(status add-frontend remove-frontend force-run).include? action
  puts optparse
  exit
end

Fog.credential = options[:credential]
ec2 = Fog::Compute.new(:provider => 'AWS')

servers = ec2.servers.all.sort{|a,b| a.tags['role'] <=> b.tags['role'] }

def running_count(servers)
   servers.count { |server| server.tags['role'].match(/^frontend\d+$/) && server.state == 'running' }
end

def add_frontend(num, servers)
  servers.each do |server|
    if server.tags['role'].match(/^frontend\d+$/) && server.state == 'stopped'
      puts "Starting '#{server.tags['role']}'"
      server.start
      num -= 1
      break if num == 0
    end
  end
end

def remove_frontend(num, servers)
  servers.reverse.each do |server|
    if server.tags['role'].match(/^frontend\d+$/) && server.state == 'running'
      next if server.tags['role'].match(/^frontend0[12]$/) 
      puts "Stopping '#{server.tags['role']}'"
      server.stop
      num -= 1
      break if num == 0
    end
  end
end

running = running_count(servers)

case action
when 'status'
  puts "# Servers for #{options[:credential]}"
  servers.each do |server|
    puts "#{server.tags['role']}, public: #{server.ip_address}, private: #{server.private_ip_address} (#{server.state})"
  end
when 'add-frontend'
  add_frontend(1, servers)
when 'remove-frontend'
  if running > 2
    remove_frontend(1, servers)
  end
when 'force-run'
  if running < options[:force_num]
    puts "Now running: #{running}, starting #{options[:force_num] - running}"
    add_frontend(options[:force_num] - running, servers)
  elsif running > options[:force_num] 
    puts "Now running: #{running}, stopping #{running - options[:force_num]}"
    remove_frontend(running - options[:force_num], servers)
  end
end

