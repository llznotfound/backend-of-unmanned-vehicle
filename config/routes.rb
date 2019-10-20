Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  get '/fog/update/:id', to: 'fog#update'
  get '/fog/alives'

  get '/barrage/update', to: 'geo#update'  #演示手机更新数据库弹幕信息
  get '/barrage/get', to: 'geo#get'  #浏览器获取更新后的弹幕接口

  get '/geo/information'  #十月份物联网项目后端接口，提供500个节点的剩余存储空间，计算能力与信道状态三个参数
  get '/geo/storm'  #十月份物联网项目后端接口，提供4个storm节点的进程工作情况，存储能力，计算负荷，各类应用通信占用带宽四个参数

  get '/ocean/all' #无人船全部数据获取接口
  get '/ocean/information' #无人船数据获取接口
  get '/ocean/info_mobile' #无人船数据移动端获取接口
  get '/ocean/water_mobile' #无人船移动端水质数据获取接口
  get '/ocean/mode' #无人船设置工作模式接口
  get '/ocean/download'
  get '/ocean/get_routes' #获取历史csv数据文件
  get '/ocean/get_csv_files'
  get '/ocean/mode_frontend'  #无人船设置工作模式前端接口
  get '/ocean/new_point'#添加路径点接口
  get '/ocean/position_mobile' #无人船移动端语音输入位置接口
  get '/ocean/position' #无人船前端获取移动端输入位置信息接口
  get '/ocean/warning_mobile' #无人船移动端获取警告信息接口
  get '/ocean/warning' #无人船前端设置警报信息接口
  get '/ocean/get_realtime_loc'
  get '/ocean/mode_return' #无人船前端一键返航指令接口
  get '/ocean/routes' #无人船添加删除工作路径点接口
  get '/ocean/control_relay' #无人船控制继电器接口
  get '/ocean/control_motor' #无人船控制电机接口
  get '/ocean/arm' #电机解锁接口
  get '/ocean/send_message' #send alarm message
  get '/ocean/disarm' #电机上锁接口
  get '/ocean/gps' #另一个GPS模块数据接口
  get '/planstatus/information', to: 'ocean#four_arguments' #无人船数据获取接口
  get '/ocean/control_frontend' #无人船前端控制电机接口 
  get '/ocean/control_manual' #无人船前段控制manual电机接口 

  #测试数据库
  get '/ocean/test_location'
  get '/ocean/test_sensor'

  get '/warehouse/update/:id', to: 'warehouse#update'
  get '/warehouse/alives'
end