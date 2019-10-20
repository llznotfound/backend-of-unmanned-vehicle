require 'net/http'

namespace :warehouse do

  task heartbeat: :environment do
    ARGV.each { |s| task s.to_sym do ; end }
    if 3 != ARGV.length
      print "wrong parameter!\n"
      print "usage: rake warehouse:heartbeat host index\n"
      next
    end

    host = ARGV[1]
    index = ARGV[2]
    path_prefix = ("/api/v2" unless host.start_with? 'localhost') || ""
    uri = URI('http://' + host + path_prefix + '/warehouse/update/' + index)
    while true
      Net::HTTP.get(uri)
      sleep 1
    end
  end

end
