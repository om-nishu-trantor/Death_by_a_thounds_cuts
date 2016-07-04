namespace :dbtc do

  desc 'stop rails'
  task :start do
    RAILS_ENV=production rails s -p 3003 -d
  end

  desc 'stop rails'
  task :stop do
    system("kill -9 $(lsof -i :3003 -t)")
  end

end