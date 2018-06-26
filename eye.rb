working_dir = File.expand_path(File.dirname(__FILE__))

Eye.config do
  logger "#{working_dir}/log/eye.log"
end

Eye.application 'blitz-tactics' do
  working_dir   working_dir
  stdall        'log/stdall.eye.log'

  process :puma do
    daemonize        true
    pid_file         'tmp/pids/eye.puma.pid'
    stdall           'log/puma.log'
    start_command    'rails s'
    stop_signals     [:TERM, 5.seconds, :KILL]
    restart_command  'pumactl restart -p {PID}'
    restart_grace    5.seconds
    monitor_children
  end
end
