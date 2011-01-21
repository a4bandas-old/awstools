gateway :dev_gateway, :address => "top.a4bandas.com", :user => "kedin"

server :staging, :user => "cms", :address => "top.a4bandas.com"
server :production, :user => "telefe", :address => "200.70.28.254", :port => 31337, :gateway => :dev_gateway

server :frontends, :user => "telefe", :addresses => [
  "fe01",
  "fe02",
  "fe03",
  "fe04",
  "fe05",
  "fe06"
]

set :stg_app_dir, '/var/www/granhermano/current'
set :prod_app_dir, '/NetApp/www/htdocs/granhermano2011.telefe.com/'
set :branch, 'upload_videos'

task :update_staging, :servers => [:staging] do
  run <<-EOC
    cd #{stg_app_dir}
    git pull origin #{branch}
    touch tmp/restart.txt
  EOC
end

task :update_production, :servers => [:production] do
  run <<-EOC
    cd #{prod_app_dir}
    git pull origin #{branch}
  EOC
end

task :restart, :servers => :frontends, :parallel => false do
  run "touch #{prod_app_dir}/tmp/restart.txt"
end
