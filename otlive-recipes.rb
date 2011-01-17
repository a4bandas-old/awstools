server :all_servers, :user => 'otlive', :addresses => [
  'otlivebe',
  'otlivelb',
  'otlivefe1',
  'otlivefe2',
  '46.51.155.80',
  '46.137.11.163',
  '46.51.143.86',
  '46.51.162.96',
  '46.51.164.99',
  '46.137.14.39',
]

server :app_servers, :user => 'otlive', :addresses => [
  'otlivefe1',
  'otlivefe2',
  '46.51.155.80',
  '46.137.11.163',
  '46.51.143.86',
  '46.51.162.96',
  '46.51.164.99',
  '46.137.14.39',
]

server :single_server, :user => 'otlive', :address => 'otlivefe1'

server :special_frontend, :user => 'otlive', :address => "46.137.117.188" 

set :app_dir, '/var/www/otlive'
set :branch, 'otlive_production'

task :update, :servers => :all_servers do
  run <<-EOC
    cd #{app_dir}
    git pull origin #{branch}
  EOC
end

task :update_special, :servers => :special_frontend do
  run <<-EOC
    cd /var/www/cmsposter
    git pull origin master
    touch tmp/restart.txt
  EOC
end

task :migrate, :servers => :single_server do
  run <<-EOC
    cd #{app_dir}
    rake db:migrate
  EOC
end

task :delayed_job_restart, :servers => :app_servers do
  run <<-EOC
    cd #{app_dir}
    ./script/delayed_job restart
  EOC
end

task :backgroup_pub_restart, :servers => :single_server do
  run <<-EOC
    cd #{app_dir}
    ./script/background_publish restart
  EOC
end

task :whenever, :servers => :single_server do
  run <<-EOC
    cd #{app_dir}
    whenever --update
  EOC
end

task :restart, :servers => :app_servers, :parallel => false do
  run "touch #{app_dir}/tmp/restart.txt"
end

task :status, :servers => :all_servers do
  run "w | grep average; netstat -nat | grep ESTABLISH | wc -l"
end

