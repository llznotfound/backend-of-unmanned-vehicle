module Modbus
  # id 取值1～8， 控制8个抽水继电器
  # action 取值0代表打开继电器，17代表关闭继电器
  def control_relay(id, action)
    header = "\xee\xff"
    payload_1 = [id].pack('C')
    payload_2 = [action].pack('C')
    checksum = [id ^ action].pack('C')
    header + payload_1 + payload_2 + checksum
  end

  # meter 0=>0.25m, 1=>0.5m, 2=>1m, 3=>1.5m, 4=>2m, 5=>2.5m, 6=>3m
  # action 0 放线 1 收线 2 电机停止
  def control_motor(meter, action)
    header = "\xee\xff"
    payload_1 = "\x0a"
    payload_2 = [action.to_s + meter.to_s].pack('H*')
    checksum = [payload_1.unpack('C')[0] ^ payload_2.unpack('C')[0]].pack('C')
    header + payload_1 + payload_2 + checksum
  end

  # 请求水质传感器数据
  def sensor_request
    header = "\xee\xff"
    payload_1 = "\x0c"
    payload_2 = "\x04"
    checksum = "\x08"
    header + payload_1 + payload_2 + checksum
  end

  # 获取水质传感器数据
  def sensor_get(top)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      # If you pass a block to the get method, then it will loop
      c.get(top) do |topic, message|
        begin
          if rand > 0.3
            next
          end
          puts "#{Time.new}: #{topic}: #{message.unpack('H*')[0]}"
          #message = message[5..-1]
          if message[2].unpack('H*')[0] == "fb" # 解析电压值
            voltage1 = (message[3..4]).unpack('s')[0].round(2)
            voltage1 = voltage1 / 1000
            voltage2 = (message[5..6]).unpack('s')[0].round(2)
            voltage2 = voltage2 / 1000
            puts '**********voltage1**********' + voltage1.to_s
            puts '**********voltage2**********' + voltage2.to_s
            PlanStatus.first.update({:voltage1 => voltage1, :voltage2 => voltage2})
          elsif message[3] == "\x2d"  # 解析水质传感器返回的电导，ph，溶氧，浊度値
            conductivity = (message[9..10] + message[7..8]).unpack('g')[0].round(2)
            ph = (message[17..18] + message[15..16]).unpack('g')[0].round(2)
            oxygen = (message[25..26] + message[23..24]).unpack('g')[0].round(2)
            turbidity = (message[33..34] + message[31..32]).unpack('g')[0].round(2)
            temperature = (message[41..42] + message[39..40]).unpack('g')[0].round(2)
            data = {:conductivity=> conductivity, :ph => ph, :oxygen=>oxygen, :turbidity=>turbidity, :temperature=>temperature}
            PlanStatus.first.update(data)
            puts data
          end
        rescue => e
          puts e.message
          puts e.backtrace
        end
      end
    end
  end

  # TODO 此处message比较时，message[2]按理说是"\xf0"，但是与"\xf0"直接比较为false，但是它们的bytes都是240。
  # TODO 上文中对"\x25"的比较可以产生正确结果。

  def send_control_relay(id, action)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      # If you pass a block to the get method, then it will loop
      OceanController.mqttsend '/sensor/control/1', OceanController.control_relay(id, action)
      send_time = Time.new
      c.get('/sensor/status') do |topic, message|
        begin
          puts "#{Time.new}: #{topic}: #{message.unpack('H*')[0]}"
          message = message[2..3].unpack('H*')[0]
          if message == "f000" || message == "f001"
            return {:status => 'ok'}
          elsif
            Time.new - send_time > 10 #发送10秒后船体仍无响应则自动回复请求失败
            return {:status => 'wrong'}
          end
        rescue => e
          puts e.message
        end
      end
    end
  end

  def send_control_motor(meter, action)
    MQTT::Client.connect(OceanController::SERVER) do |c|
      # If you pass a block to the get method, then it will loop
      OceanController.mqttsend '/sensor/control/1', OceanController.control_motor(meter, action)
      send_time = Time.new
      c.get('/sensor/status') do |topic, message|
        begin
          puts "#{Time.new}: #{topic}: #{message.unpack('H*')[0]}"
          message = message[2..3].unpack('H*')[0]
          if message == "f000" || message == "f001"
            return {:status => 'ok'}
          elsif
            Time.new - send_time > 10 #发送10秒后船体仍无响应则自动回复请求失败
            return {:status => 'wrong'}
          end
        rescue => e
          puts e.message
        end
      end
    end
  end
end
