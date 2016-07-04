namespace :dbtc do

  desc 'start rails'
  task :start do
    exec("rails server -e production -p 3003 -d")
  end

  desc 'stop rails'
  task :stop do
    system("kill -9 $(lsof -i :3003 -t)")
  end

  desc 'restart rails'
  task :restart do
    system("kill -9 $(lsof -i :3003 -t)")
    exec("rails server -e production -p 3003 -d")
  end

end