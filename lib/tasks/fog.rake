require 'net/http'
require 'net/ping'

namespace :fog do

  desc "维持指定节点的心跳包"
  task heartbeat: :environment do
    ARGV.each { |s| task s.to_sym do ; end }
    if 3 != ARGV.length
      print "wrong parameter!\n"
      print "usage: rake fog:heartbeat host index\n"
      next
    end

    host = ARGV[1]
    index = ARGV[2]
    path_prefix = ("/api/v2" unless host.start_with? 'localhost') || ""
    uri = URI('http://' + host + path_prefix + '/fog/update/' + index)
    while true
      Net::HTTP.get(uri)
      sleep 1
    end
  end

  def heartbeat(ip, index, path)
    uri = URI(path + index.to_s)
    while true
      check = Net::Ping::External.new(ip)
      if check.ping?
        Net::HTTP.get(uri)
      end
      sleep 1.seconds
    end
  end

  task live_detect: :environment do
    nodes = [{ip: '192.168.1.11', index: 1},
             {ip: '192.168.1.13', index: 2},
             {ip: '192.168.1.16', index: 3},
             {ip: '192.168.1.17', index: 4},]
    path = 'http://demo.iot.sjtudoit.cn/api/v2/fog/update/'
    nodes.each do |node|
      Thread.new{heartbeat(node[:ip], node[:index], path)}
    end

    # 死循环防止退出
    while true
      sleep 5.seconds
    end
  end

  task node_move: :environment do
    11.times do
      Thread.new{GeoNode.move}
      sleep 5.seconds
    end
  end

  task reset_position: :environment do
    GeoNode.reset
  end
end
