# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
env :PATH, ENV['PATH']
set :environment, :development
# #模拟节点运动
# every 1.minute do
#   rake "fog:node_move"
# end

# #节点位置重新分布，防止跑偏
# every 1.day, :at => '0:01 am' do
#   rake "fog:reset_position"
# end
every 1.minute do
  rake "ocean:write_data"
  command "scp -r /home/dong/Desktop/codes/iot-demo-backend/log/data bike@116.62.213.180:/home/bike/iotBackup/"
end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
