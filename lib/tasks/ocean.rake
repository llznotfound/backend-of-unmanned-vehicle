namespace :ocean do

  desc "监听mqtt服务器/usv/status通道"
  task mqttget: :environment do
    OceanController.mqttget '/usv/status'
  end

  desc "监听mqtt服务器/sensor/status通道"
  task sensor_get: :environment do
    OceanController.sensor_get '/sensor/status'
  end

  desc "将船体坐标写入excel表格中"
  task write_excel: :environment do
    begin
      excel = Spreadsheet::Workbook.new
      sheet = excel.create_worksheet :name => 'location'
      sheet.row(0).push '序号', '经度', '纬度', '时间'
      i = 0
      while true
        i = i + 1
        puts "正在写第#{i}行"
        OceanController.write_location(sheet, i)
        sleep 1
      end
    rescue => e
      puts e.message
      puts e.backtrace
    ensure
      excel.write "#{Rails.root.to_s}/log/location.xls"
    end
  end

  desc "将数据库数据写入文件中"
  task write_data: :environment do
    begin
      OceanController.mqttsend '/sensor/control/1', OceanController.sensor_request
      data = Ocean.information
      aFile = File.new("#{Rails.root.to_s}/log/data","a+")
      if aFile
        aFile.syswrite(data)
      else 
        puts "Unable to open file!"
      end
    end
  end

end
