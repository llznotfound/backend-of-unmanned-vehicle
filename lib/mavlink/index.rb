require_relative 'message'
require_relative 'header'
require_relative 'entry'
require_relative 'messages/messages'

module Communicate
  def mqttsend(topic, message)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      c.publish(topic, message)
    end
  end

  def mqttget(top)
    Thread.new do
      OceanController.start_udp_server #监听udp端口获取GPS模块定位信息
    end
    MQTT::Client.connect(OceanController::SERVER) do |c|
      # If you pass a block to the get method, then it will loop
      c.get(top) do |topic,message|
        begin
          #puts message.unpack('H*')[0]
          #print message.unpack('H*')[0][10..11]+' '
          header = MAVLink::Header.new(message[0..5])
          # if rand < 0.3 && [0, 1, 33, 39, 40, 44, 47, 77, 109].include?(header.id)
          if [0, 1, 33, 39, 40, 44, 47, 77, 109].include?(header.id)
            payload = message[6..-3]
            crc = message[-2..-1]
            entry = MAVLink::Entry.new(header, payload, crc)
            decode = MAVLink::Messages::Factory.build(entry)
            puts "#{Time.new}: #{topic}: #{message.unpack('H*')[0]}: #{decode.inspect}"
          end
        rescue => e
          puts e.message
          puts e.backtrace
        end
      end
    end
  end

  # 处理添加删除关键路径点相关交互操作
  def mqttget_routes(count, lngs, lats)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      # If you pass a block to the get method, then it will loop
      OceanController.mqttsend '/usv/control/1', OceanController.send_mission_count(count)
      c.get('/usv/status') do |topic, message|
        begin
          header = MAVLink::Header.new(message[0..5])
          payload = message[6..-3]
          crc = message[-2..-1]
          entry = MAVLink::Entry.new(header, payload, crc)
          if entry.header.id == 40
            result = MAVLink::Messages::MissionRequest.new(entry)
            if result.seq == 0
              OceanController.mqttsend '/usv/control/1', OceanController.send_mission_item(result.seq, lats[result.seq], lngs[result.seq])
            elsif result.seq == count - 1
              OceanController.mqttsend '/usv/control/1', OceanController.send_mission_item(result.seq, lats[result.seq], lngs[result.seq])
            else 
              OceanController.mqttsend '/usv/control/1', OceanController.send_mission_item_twenty(result.seq, lats[result.seq], lngs[result.seq])
            end
          elsif entry.header.id == 47
            result = MAVLink::Messages::MissionAck.new(entry)
            if result.type == 0
              return {:status => 'ok'}
            end
          end
        rescue => e
          puts e.message
          puts e.backtrace
        end
      end
    end
  end

  #设置自动模式下的航行参数
  def mqttget_action(count ,delays, lefts , rights , lng , lat)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      OceanController.mqttsend '/usv/control/1',OceanController.send_mission_count(count * 2 + 1)
      c.get('/usv/status') do |topic , message|
        begin
          header = MAVLink::Header.new(message[0..5])
          payload = message[6..-3]
          crc = message[-2..-1]
          entry = MAVLink::Entry.new(header, payload, crc)
          if entry.header.id == 40
            result = MAVLink::Messages::MissionRequest.new(entry)
            if result.seq == 0
              OceanController.mqttsend '/usv/control/1', OceanController.send_mission_item(result.seq ,lat,lng)
            elsif result.seq % 2 == 0
              OceanController.mqttsend '/usv/control/1', OceanController.send_mission_item_control(delays[result.seq/2-1],lefts[result.seq/2-1],rights[result.seq/2-1],93,result.seq,lng,lat)
            else 
              OceanController.mqttsend '/usv/control/1', OceanController.send_mission_item_control(255,lefts[result.seq/2],rights[result.seq/2],183,result.seq,lng,lat)
            end
          elsif entry.header.id == 47
            result = MAVLink::Messages::MissionAck.new(entry)
            if result.type == 0
              return {:status => 'ok'}
            end
          end
        rescue => e
          puts e.message
          puts e.backtrace
        end
      end
    end
  end

  def send_arm_or_disarm(type)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      # If you pass a block to the get method, then it will loop
      if type == 'arm'
        OceanController.mqttsend '/usv/control/1', OceanController.send_command_long_arm
      elsif type == 'disarm'
        OceanController.mqttsend '/usv/control/1', OceanController.send_command_long_disarm
      end
      c.get('/usv/status') do |topic, message|
        begin
          header = MAVLink::Header.new(message[0..5])
          payload = message[6..-3]
          crc = message[-2..-1]
          entry = MAVLink::Entry.new(header, payload, crc)
          if entry.header.id == 77
            command_ack = MAVLink::Messages::CommandAck.new(entry)
            puts '*****command_act result*****' +command_ack.result
            if command_ack.result == 0
              return {:status => 'ok'}
            else
              return {:status => 'error'}
            end
          elsif entry.header.id == 0
            heartbeat = MAVLink::Messages::HeartBeat.new(entry)
            puts '*****heartbeat base_mode*****' + heartbeat.base_mode
          end
        rescue => e
          puts e.message
          puts e.backtrace
        end
      end
    end
  end

  #监听通道信息
  def mqttget_puts(topic)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      c.get(topic) do |topic,message|
        begin
          # puts message.unpack('H*')[0]
          # print message.unpack('H*')[0][10..11]+' '
          header = MAVLink::Header.new(message[0..5])
          payload = message[6..-3]
          crc = message[-2..-1]
          entry = MAVLink::Entry.new(header, payload, crc)
          decode = MAVLink::Messages::Factory.build(entry)
          puts "#{topic}: 'header.id:' #{header.id}: #{decode.inspect}"
          # puts "#{topic}: 'header.magic:' #{header.magic}: 'header.length:'#{header.length}: 
          # 'header.sequence:' #{header.sequence}: 'header.system:' #{header.system}: 
          # 'header.component:' #{header.component}: 'header.id:' #{header.id}: #{decode.inspect}"
        end
      end
    end
  end

  def mqttget_puts_backup(topic)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      c.get(topic) do |topic,message|
        begin
          header = MAVLink::Header.new(message[0..5])
          if [40, 47].include?(header.id)
            payload = message[6..-3]
            crc = message[-2..-1]
            entry = MAVLink::Entry.new(header, payload, crc)
            decode = MAVLink::Messages::Factory.build(entry)
            puts "#{Time.new}: #{topic}: #{message.unpack('H*')[0]} #{header.id}: #{decode.inspect}"
          end
        end
      end
    end
  end

  def send_set_mode(mode)
    header = MAVLink::SendHeader.new(254,6,0,0,0,11)
    message = MAVLink::Messages::SendSetMode.new(header)
    message.custom_mode(mode)
    message.target_system(0)
    message.base_mode(1)
    message.code
  end

  def send_mission_count(num)
    header = MAVLink::SendHeader.new(254,4,0,0,0,44)
    message = MAVLink::Messages::SendMissionCount.new(header)
    message.count(num)
    message.target_system(1)
    message.target_component(0)
    #message.mission_type(0)
    message.code
  end

  def send_mission_item(num, x, y)
    header = MAVLink::SendHeader.new(254,37,85,252,1,39)
    message = MAVLink::Messages::SendMissionItem.new(header)
    message.param1(0)
    message.param2(0)
    message.param3(0)
    message.param4(0)
    message.x(x)
    message.y(y)
    message.z(0)
    message.seq(num)
    message.command(16)
    message.target_system(1)
    message.target_component(190)
    message.frame(3)
    message.current(0)
    message.autocontinue(1)
    #message.mission_type(0)
    message.code
  end

  def send_mission_item_twenty(num, x, y)
    header = MAVLink::SendHeader.new(254,37,85,252,1,39)
    message = MAVLink::Messages::SendMissionItem.new(header)
    message.param1(20)
    message.param2(0)
    message.param3(0)
    message.param4(0)
    message.x(x)
    message.y(y)
    message.z(0)
    message.seq(num)
    message.command(16)
    message.target_system(1)
    message.target_component(190)
    message.frame(3)
    message.current(0)
    message.autocontinue(1)
    #message.mission_type(0)
    message.code
  end

  def send_mission_item_control(param1, x, y,command,num,lng,lat)
    header = MAVLink::SendHeader.new(254,37,85,252,1,39)
    message = MAVLink::Messages::SendMissionItem.new(header)
    message.param1(param1)
    message.param2(x)
    message.param3(y)
    message.param4(0)
    message.x(lat)
    message.y(lng)
    message.z(0)
    message.seq(num)
    message.command(command)
    message.target_system(1)
    message.target_component(190)
    message.frame(3)
    message.current(0)
    message.autocontinue(1)
    #message.mission_type(0)
    message.code
  end

  def send_mission_manual_control(x,y)
    header = MAVLink::SendHeader.new(254,11,0,255,0,69)
    message = MAVLink::Messages::SendMissionManualControl.new(header)
    message.x(x)
    message.y(y)
    message.z(0)
    message.r(0)
    message.buttons(0)
    message.target(1)
    message.code
  end

  def send_mission_request_list
    header = MAVLink::SendHeader.new(254,2,43,252,1,43)
    message = MAVLink::Messages::SendMissionRequestList.new(header)
    message.target_system(1)
    message.target_component(190)
    #message.mission_type(0)
    message.code
  end

  def send_mission_request(num)
    header = MAVLink::SendHeader.new(254,4,5,252,1,40)
    message = MAVLink::Messages::SendMissionRequest.new(header)
    message.seq(num)
    message.target_system(1)
    message.target_component(190)
    #message.mission_type(0)
    message.code
  end

  def send_mission_act
    header = MAVLink::SendHeader.new(254,3,6,252,1,47)
    message = MAVLink::Messages::SendMissionAck.new(header)
    message.target_system(252)
    message.target_component(1)
    message.type(0)
    #message.mission_type(0)
    message.code
  end

  def send_mission_clear_all
    header = MAVLink::SendHeader.new(254,3,7,252,1,45)
    message = MAVLink::Messages::SendMissionClearAll.new(header)
    message.target_system(1)
    message.target_component(1)
    #message.mission_type(0)
    message.code
  end

  #电机解锁
  def send_command_long_arm
    message = "\xfe\x21\x0\x0\x0\x4c\x0\x0\x80\x3f\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x90\x1\x0\x0\x0\x76\x34"
    message.unpack('C*').pack('C*')
  end

  #电机上锁
  def send_command_long_disarm
    message = "\xfe\x21\x0\x0\x0\x4c\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x0\x90\x1\x0\x0\x0\x10\x50"
    message.unpack('C*').pack('C*')
  end
end