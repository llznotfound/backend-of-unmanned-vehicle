require 'mavlink/index'
require 'modbus/modbus'
require 'spreadsheet'
require 'socket'
require 'csv'
#require 'aliyunsdkcore'

class OceanController < ApplicationController
  SERVER = 'localhost'
  # SERVER = '192.168.1.110'

  def all
    # self.class.mqttsend '/sensor/control/1', self.class.sensor_request
    data = Ocean.information
    render json: data, callback: params['callback']
  end

  def information
    ocean = Ocean.first
    data = {:speed => ocean.speed,
            :angle => ocean.angle,
            :communicate => ocean.communicate,
            :time => ocean.time,
            :battery => ocean.battery,
            :radius => ocean.radius}
    render json: data, callback: params['callback']
  end

  def four_arguments
    self.class.mqttsend '/sensor/control/1', self.class.sensor_request
    plan = PlanStatus.first
    data = {:ph => plan.ph,
            :conductivity => plan.conductivity,
            :turbidity => plan.turbidity,
            :oxygen => plan.oxygen,
            :temperature => plan.temperature,
            :voltage1 => plan.voltage1,
            :voltage2 => plan.voltage2,
            :lng => plan.lng,
            :lat => plan.lat}
    render json: data, callback: params['callback']
  end

  def water_mobile
    plan = PlanStatus.first
    data = {:ph => plan.ph,
            :conductivity => plan.conductivity,
            :turbidity => plan.turbidity,
            :oxygen => plan.oxygen,
            :temperature => plan.temperature,
            :voltage1 => plan.voltage1,
            :voltage2 => plan.voltage2,
            :lng => plan.lng,
            :lat => plan.lat}
    render json: data
  end

  # 移动端获取六参数接口（暂时只有3个是来自真实数据源）
  def info_mobile
    ocean = Ocean.first
    data = {:speed => ocean.speed,
            :angle => ocean.angle,
            :communicate => ocean.communicate,
            :time => ocean.time,
            :battery => ocean.battery,
            :radius => ocean.radius}
    render json: data
  end

  # 根据移动端语音输入处理结果设置无人船工作模式
  # 4：停止
  # 10：开始
  # 11：返航
  # 15：绕开
  # 20：反推
  def mode
    new_mode = params['mode'].to_i
    if [4,10,11,15,20].include?(new_mode)
      if new_mode == 11 #处理返航模式，设置返航点
        position = Route.first
        if position != nil
          self.class.mqttget_routes(1, [position.lng], [position.lat])
        end
      elsif new_mode == 15 #处理绕开模式，自动生成一个路径点
        position = Route.last
        if position != nil
          Route.create(:lng => position.lng + 0.001, :lat => position.lat + 0.0005)
          self.class.mqttget_routes(1, [position.lng + 0.001], [position.lat + 0.0005])
        end
      else
        self.class.mqttsend '/usv/control/1', self.class.send_command_long_arm
      end
      self.class.mqttsend '/usv/control/1', self.class.send_set_mode(new_mode)
      render json: {:status => 'ok'}
    else
      render json: {:status => 'wrong'}
    end
  end

  #get the real-time location of the car, update the sql
  def get_realtime_loc
    rev_lat = params['lat'].to_f
    rev_lng = params['lng'].to_f
    plan = PlanStatus.first
    plan.lat = rev_lat
    plan.lng = rev_lng
    plan.save      #save to the sql
    render json:{:status => 'ok'}
  end

  #send alarm message
  def send_message
    rev_lat = params['lat']
    rev_lng = params['lng']
    code = rev_lat+","+rev_lng
    client = RPCClient.new(
        access_key_id:     '<accessKeyId>',
        access_key_secret: '<accessSecret>',
        endpoint: 'https://dysmsapi.aliyuncs.com',
        api_version: '2017-05-25'
    )

    response = client.request(
        action: 'SendSms',
        params: {
            RegionId: "cn-hangzhou",
            PhoneNumbers: "18217260862",
            SignName: "Unmanned Car",
            TemplateCode: "您的小车在${code}发生故障",
            TemplateParam: code
        },
        opts: {
            method: 'POST'
        }
    )

    render json:{:status => response}
  end
  def new_point
    lat = params['lat']
    lng = params['lng']
    lat = lat.to_f * 1
    lng = lng.to_f * 1
    #将路径点的经纬度写入CSV文件
    if File::exists?("#{Rails.root}/demo.csv")# => true
      arr=CSV.read("#{Rails.root}/demo.csv")
      id = arr[arr.length-1,arr.length]
      i=id[0][0].to_i
      CSV.open("#{Rails.root}/demo.csv","a") do |csv|
      csv << [i+1,lat,lng]     
      end
    else
      File.new("#{Rails.root}/demo.csv","w")
      CSV.open("#{Rails.root}/demo.csv","a") do |arr|
      id = 1
      arr << ['id','lat','lng']
      arr << [id,lat,lng]
      end
    end
    render json: {:status => 'ok'}, callback: params['callback']
  end

  # 前端设置工作模式接口
  def mode_frontend
    new_mode = params['mode'].to_i
    socket = TCPSocket.open('192.168.1.102', 8888)
    if [0,4,8,10,11,15,20,50].include?(new_mode)
      if new_mode == 0  #启动
        puts('启动')
        socket.puts('M')
      elsif new_mode == 4 #直行su
        # socket.puts('123')
        socket.puts('D')
        puts('直行')
      elsif new_mode == 8 #后退
        # socket.puts('123')
        socket.puts('B')
        puts('后退')
      elsif new_mode == 20 #左转
        # socket.puts('456')
        socket.puts('L')
        puts('左转')
      elsif new_mode == 15 #右转
        # socket.puts('789')
        socket.puts('R')
      elsif new_mode == 10 #停 是前端的停 不是停止 目前加入自动操作的停止
        socket.puts('S')

     #   socket.puts('M')
      end
      socket.close()
      render json: {:status => 'ok'}, callback: params['callback']
    else
      render json: {:status => 'error'}, callback: params['callback']
    end
  end

  def get_csv_files
    car = params['car']
    file_list = []
    Dir.foreach("#{Rails.root}/csv/#{car}") do |filename|
      if filename != '.' && filename != '..'
        file_list.push(filename)
      end
    end
    render json: {:status => 'ok', :file_list => file_list}, callback: params['callback']
  end

  def get_routes
    car = params['car']
    file_name = params['file_name']
    routes_arr = CSV.read("#{Rails.root}/csv/#{car}/#{file_name}")
    routes_arr = routes_arr[1, routes_arr.length]
    routes = []
    routes_arr.each do |index, lat, lng|
      routes[index.to_i - 1] = { :lng => lng.to_f / 100, :lat => lat.to_f / 100, :status => 'doing'}
    end
=begin
    CSV.foreach("#{Rails.root}/test.csv") do |row, index|
      puts row
      puts index
    end
=end
    render json: {:status => 'ok', :routes => routes}, callback: params['callback']
  end

  def download
    send_file "test.csv"
    #send_file "public/files/"+params[:filename] unless params[:filename].blank?
  end

  # 设置关键路径点
  def routes
    mode = params['mode'].to_i 
    if mode==50
      File.delete("#{Rails.root}/test.csv")
      File.rename("#{Rails.root}/demo.csv","#{Rails.root}/test.csv")
      render json: {:status => 'ok'} , callback: params['callback']
    else
      render json: {:status => 'error'} , callback: params['callback']
    end
    #render json: self.class.mqttget_routes(count, lngs, lats), callback: params['callback']
  end

  # 前端手动控制电机接口
  def control_frontend
    lng = params['lng'].to_f
    lat = params['lat'].to_f
    count = params['count'].to_i
    lefts = []
    rights = []
    delays = []
    count.times do |i|
      left = params["left_pwn#{i}"].to_i
      right = params["right_pwn#{i}"].to_i
      delay = params["delay_time#{i}"].to_i
      lefts << left
      rights << right
      delays << delay
    end
    render json: self.class.mqttget_action(count,delays,lefts,rights,lng,lat) , callback: params['callback']
  end

  # 前段设置manual电机参数
  def control_manual
    count = params['count'].to_i
    lefts = []
    rights = []
    count.times do |i|
      left = params["left_pwn#{i}"].to_i
      right = params["right_pwn#{i}"].to_i
      lefts << left
      rights << right
      self.class.mqttsend '/usv/control/1' , self.class.send_mission_manual_control(left,right)
      if(i == 0)
        render json: {:status => 'ok'} , callback: params['callback']
      end
      sleep 1
    end
    
  end

  # TODO params[:action]获取不到参数，url不能带action的参数？

  # id 取值1～8， 控制8个抽水继电器
  # action 取值0代表打开继电器，17代表关闭继电器
  def control_relay
    id = params['id'].to_i
    action = params['act'].to_i
    if (1..8) === id && [0, 17].include?(action)
      render json: self.class.send_control_relay(id, action), callback: params['callback']
    else
      render json: {:status => 'wrong_params'}, callback: params['callback']
    end
  end

  # meter 取值0.25m 0.5m 1m 1.5m 2m 2.5m 3m
  # action 0 放线 1 收线 2 电机停止
  def control_motor
    meter = params['meter'].to_i
    action = params['act'].to_i
    meter = (meter * 2).ceil
    if (0..6) === meter && (0..2) === action
      render json: self.class.send_control_motor(meter, action), callback: params['callback']
    else
      render json: {:status => 'wrong_params'}, callback: params['callback']
    end
  end

  #无人船移动端语音输入位置
  def position_mobile
    lng = params['lng'].to_f
    lat = params['lat'].to_f
    if Info.first.update({:lng => lng, :lat=>lat, :checked => false})
      render json: {:status => 'ok'}
    else
      render json: {:status => 'wrong'}
    end
  end

  #无人船前端获取语音输入位置
  def position
    info = Info.first
    if !info.checked
      info.update({:checked => true})
      render json: {:lng => info.lng, :lat => info.lat, :status => "ok"}, callback: params['callback']
    else
      render json: {:status => 'checked'}, callback: params['callback']
    end
  end

  #无人船移动端获取警告信息
  def warning_mobile
    render json: {:status => Info.first.warning}
  end

  #无人船前端设置警报信息
  def warning
    warning = params['warning'] == 'true'
    Info.first.update(:warning => warning)
    render json: {:status => 'ok'}, callback: params['callback']
  end

  # 前端一键返航指令接口
  def mode_return
    self.class.mqttsend '/usv/control/1', self.class.send_set_mode(11)
    render json: {:status => 'ok'}, callback: params['callback']
  end

  # 获取测试船体坐标数据
  def test_location
    test = Test.first
    lng = (test.lng + Random.rand(0.00001) - 0.000005).round(6)
    lat = (test.lat + Random.rand(0.00001) - 0.000005).round(6)
    result = {:lng => lng, :lat => lat}
    Test.update(result)
    render json: result, callback: params['callback']
  end

  # 获取测试传感器数据
  def test_sensor
    test = Test.first
    temperature = (test.temperature + Random.rand(1.0) - 0.5).round(2)
    ph = (test.ph + Random.rand(0.5) - 0.25).round(2)
    conductivity = (test.conductivity + Random.rand(0.2) - 0.1).round(2)
    turbidity = (test.turbidity + Random.rand(0.2) - 0.1).round(2)
    oxygen = (test.oxygen + Random.rand(0.2) - 0.1).round(2)
    result = {:temperature => temperature,
              :ph => ph,
              :conductivity => conductivity,
              :turbidity => turbidity,
              :oxygen => oxygen}
    Test.update(result)
    render json: result, callback: params['callback']
  end

  #电机解锁
  def arm
    render json: self.class.send_arm_or_disarm('arm'), callback: params['callback']
  end

  #电机上锁
  def disarm
    render json: self.class.send_arm_or_disarm('disarm'), callback: params['callback']
  end

  #获取另一个GPS模块数据
  def gps
    render json: GpsLocation.info, callback: params['callback']
  end

  class << self
    include Communicate
    include Modbus

    def test_csv
      CSV.foreach("#{Rails.root}/test.csv") do |row|
        puts row
      end
    end

    def write_location (sheet, i)
      plan_status = PlanStatus.first
      sheet.row(i).push i, plan_status.lng, plan_status.lat, Time.now.to_s
    end

    def start_udp_server
      socket = UDPSocket.new
      socket.bind("192.168.1.110", 1999)
      loop do
        msg = socket.recvfrom(1024)
        arr = msg[0].split(',')
        puts msg[0]
        case arr[0]
        when '$GPGGA'
          lat = arr[2].to_f/100
          lng = arr[4].to_f/100
          puts '*****lat, lng*****'
          puts lat, lng
          GpsLocation.first.update(:lat => lat, :lng => lng)
        when '$GPRMC'
          lat = arr[3].to_f/100
          lng = arr[5].to_f/100
          puts '*****lat, lng*****'
          puts lat, lng
          GpsLocation.first.update(:lat => lat, :lng => lng)
        when '#HEADINGA'
          heading = arr[12].to_f
          puts '*****heading*****'
          puts heading
          GpsLocation.first.update(:heading => heading)
        else
          nil
        end
      end
    end

    def send_udp_datagram
      socket = UDPSocket.new
      socket.connect("192.168.1.110", 1999)
      arr = ['$GPGGA,030940.00,3053.2782871,N,12143.5443069,E,1,20,0.8,25.4571,M,12.935,M,99,0000*6D',
      '$GPGLL,3053.2782871,N,12153.5443069,E,030940.00,A,D*6B',
      '$GNGSA,M,3,01,03,08,11,17,18,22,28,30,,,,1.6,0.8,1.4*26',
      '$GNGSA,M,3,141,147,148,150,153,,,,,,,,1.6,0.8,1.4*12',
      '$GNGSA,M,3,45,51,52,54,60,61,,,,,,,1.6,0.8,1.4*28',
      '$GPGSV,3,1,12,01,68,033,53,22,41,107,47,30,42,240,35,03,35,139,38*71',
      '$GPGSV,3,2,12,17,27,290,38,08,23,071,40,07,29,204,,19,05,274,*75',
      '$GPGSV,3,3,12,06,04,225,,28,55,328,51,11,54,035,51,18,41,041,47*73',
      '$BDGSV,2,1,05,141,50,147,49,147,68,171,51,148,69,286,51,150,75,272,51*60',
      '$BDGSV,2,2,05,153,52,255,41,,,,,,,,,,,,*6A',
      '$GLGSV,2,1,06,51,70,251,52,60,17,042,44,52,41,320,51,61,49,358,48*6B',
      '$GLGSV,2,2,06,45,12,055,34,54,39,283,45,,,,,,,,*65',
      '$GPRMC,030940.00,A,3053.2782871,N,12153.5443069,E,000.037,218.4,270718,0.0,W,D*25',
      '$GPVTG,218.393,T,218.393,M,0.037,N,0.068,K,D*2C',
      '#HEADINGA,COM2,0,60.0,FINESTEERING,2011,443398.000,00000000,0000,1114;SOL_COMPUTED,NARROW_INT,1.396890879,220.623992920,-6.505328655,0.0,0.0158,0.0169,"0004",12,12,12,12,0,0,0,0*9fe42a98']
      while true
        socket.write(arr[rand(15)])
        sleep 0.3
      end
    end

    def test
      array = [["fe1c8f010121dea521006d5593129e215e48a6ffffffa6ffffff1b00e7fffbffb78401c0"],
               ["fe1ca401012136a8210074559312a5215e48f80c0000f80c000023001400fcffad847f36"],
               ["fe1cb301012156ab21006e559312a7215e48080200000802000017000900fcff9f844420"],
               ["fe1c8f010121dea521006d5593128e215e48a6ffffffa6ffffff1b00e7fffbffb78401c0"],
               ["fe1ca401012136a8210074559312a8215e48f80c0000f80c000023001400fcffad847f36"],
               ["fe1cb301012156ab21006e559312a9215e48080200000802000017000900fcff9f844420"],
               ["fe1c8f010121dea521006d5593126e215e48a6ffffffa6ffffff1b00e7fffbffb78401c0"],
               ["fe1ca401012136a8210074559312a1215e48f80c0000f80c000023001400fcffad847f36"],
               ["fe1cb301012156ab21006e55931257215e48080200000802000017000900fcff9f844420"],
               ["fe1c8f010121dea521006d5593125e215e48a6ffffffa6ffffff1b00e7fffbffb78401c0"],
               ["fe1ca401012136a821007455931265215e48f80c0000f80c000023001400fcffad847f36"],
               ["fe1cb301012156ab21006e559312aa215e48080200000802000017000900fcff9f844420"]]
      while true do
        mqttsend '/usv/status', array[rand(12)].pack('H*')
        sleep 0.03
      end
    end
  end
end
