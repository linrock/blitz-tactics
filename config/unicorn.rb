# unicorn -c config/unicorn.rb

RAILS_ENV = ENV['RAILS_ENV'] || 'development'
RAILS_ROOT = Dir.pwd

if RAILS_ENV == 'production'
  # listen "#{RAILS_ROOT}/tmp/sockets/unicorn.sock"
  listen 3000
  stdout_path "#{RAILS_ROOT}/log/unicorn.stdout.log"
  stderr_path "#{RAILS_ROOT}/log/unicorn.stderr.log"
  worker_processes 2
else
  listen 3000
  worker_processes 1
end

preload_app true

pid "tmp/pids/unicorn.pid"

timeout 15


before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  # Graceful restarts via -USR2 signal
  old_pidfile = "#{RAILS_ROOT}/tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pidfile)
    begin
      Process.kill "QUIT", open(old_pidfile).read.to_i
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end
