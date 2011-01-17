server :backend, :user => 'otlive', :address => 'otlivebe'
server :load_balancer, :user => 'otlive', :address => 'otlivelb'
server :frontend1, :user => 'otlive', :address => 'otlivefe1'
server :specialfe, :user => 'otlive', :address => 'otlivesp'

server :frontends, :user => 'otlive', :addresses => [
  'otlivefe1',
  'otlivefe2',
  '46.51.155.80',
  '46.137.11.163',
#  '46.51.143.86',
#  '46.51.162.96',
#  '46.51.164.99',
#  '46.137.14.39',
]


set :app_dir, '/var/www/otlive'
set :branch, 'otlive_production'

task :update, :servers => [:backend, :load_balancer, :frontends] do
  run <<-EOC
    cd #{app_dir}
    git pull origin #{branch}
  EOC
end

task :migrate, :servers => :frontend1 do
  run <<-EOC
    cd #{app_dir}
    rake db:migrate
  EOC
end

task :delayed_job_restart, :servers => :frontends do
  run <<-EOC
    cd #{app_dir}
    ./script/delayed_job restart
  EOC
end

task :backgroup_pub_restart, :servers => :frontend1 do
  run <<-EOC
    cd #{app_dir}
    ./script/background_publish restart
  EOC
end

task :whenever, :servers => :frontend1 do
  run <<-EOC
    cd #{app_dir}
    whenever --update
  EOC
end

task :restart, :servers => :frontends, :parallel => false do
  run "touch #{app_dir}/tmp/restart.txt"
end

task :status, :servers =>  [:backend, :load_balancer, :frontends, :specialfe] do
  run "w | grep average; netstat -nat | grep ESTABLISH | wc -l"
end

