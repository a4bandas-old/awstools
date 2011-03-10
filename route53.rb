#!/usr/bin/env ruby

require 'rubygems'
require 'fog'

Fog.credential = :otlive
dns = dns = Fog::DNS.new(:provider => 'AWS')

response = dns.list_hosted_zones
if response.status != 200
  puts "Status: #{response.status}"
  exit
end

hosted_zones = response.body['HostedZones']
zone = hosted_zones.first
puts "#{zone['Name']} -> #{zone['Id']}"

# create an A resource record
#host = zone['Name']
#ip_addrs = ['46.137.124.172']
#resource_record = { :name => host, :type => 'A', :ttl => 3600, :resource_records => ip_addrs }
#resource_record_set = resource_record.merge( :action => 'CREATE')

#change_batch = []
#change_batch << resource_record_set
#options = { :comment => 'add A record to domain'}             
#response = dns.change_resource_record_sets( zone['Id'], change_batch, options)

#puts response.inspect

# create a CNAME resource record
#host = '*.kedinlive.es.'
#value = ['kedinlive.es.']
#resource_record = { :name => host, :type => 'CNAME', :ttl => 3600, :resource_records => value }
#resource_record_set = resource_record.merge( :action => 'CREATE')

#change_batch = []
#change_batch << resource_record_set
#options = { :comment => 'add CNAME record to domain'}             
#response = dns.change_resource_record_sets( zone['Id'], change_batch, options)

#puts response.inspect

response = dns.list_resource_record_sets(zone['Id'])
if response.status == 200
  puts "Num. records: #{response.body['ResourceRecordSets'].count}"
  response.body['ResourceRecordSets'].each do |r|
    puts r.inspect
  end
end

