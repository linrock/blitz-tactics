# Tasks related to unicorn server

namespace :unicorn do

  desc "Run server in foreground"
  task :run do
    exec "bundle exec unicorn -c config/unicorn.rb"
  end

  desc "Run server in background"
  task :start do
    `bundle exec unicorn -D -c config/unicorn.rb`
  end

  desc "Gracefully restart server (-USR2)"
  task :restart do
    `kill -USR2 #{open('tmp/pids/unicorn.pid').read}`
  end

  desc "Quit server"
  task :quit do
    `kill -QUIT #{open('tmp/pids/unicorn.pid').read}`
  end

end
