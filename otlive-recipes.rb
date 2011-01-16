server :all_servers, :user => 'otlive', :addresses => [
  'otlivebe',
  'otlivelb',
  'otlivefe1',
  'otlivefe2',
  'otlivefe3',
  'otlivefe4',
  'otlivefe5',
  'otlivefe6'
]

server :app_servers, :user => 'otlive', :addresses => [
  'otlivefe1',
  'otlivefe2',
  'otlivefe3',
  'otlivefe4',
  'otlivefe5',
  'otlivefe6'
]

server :single_server, :user => 'otlive', :address => 'otlivefe1'

set :app_dir, '/var/www/otlive'
set :branch, 'otlive_production'

task :update, :servers => :all_servers do
  run <<-EOC
    cd #{app_dir}
    git pull origin #{branch}
  EOC
end

task :migrate, :servers => :single_server do
  run <<-EOC
    cd #{app_dir}
    rake db:migrate
  EOC
end

task :restart, :servers => :app_servers, :parallel => false do
  run "touch #{app_dir}/tmp/restart.txt"
end

