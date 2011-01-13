use 'otlive-servers.rb'

set :app_dir, '/var/www/otlive'
set :branch, 'otlive_production'

task :update, :servers => :fe_servers do
  run <<-EOC
    cd #{app_dir}
    git pull origin #{branch}
  EOC
end

task :migrate, :servers => :fe_servers do
  run <<-EOC
    cd #{app_dir}
    rake db:migrate
  EOC
end

task :restart, :servers => :fe_servers do
  run "touch #{app_dir}/tmp/restart.txt"
end

