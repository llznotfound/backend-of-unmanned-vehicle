# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

=begin
16.times do |ii|
  FogComputingNode.create
end

16.times do |ii|
  WarehouseNode.create
end

#1号节点，用于演示手机发送信息至服务器
GeoNode.create(:lng=>114.004918,:lat=>22.60148)

499.times do |ii|
  #模拟数据的节点位置在深圳市区内
  GeoNode.create(:lng=>Random.rand(114.001163..114.012195).round(6),:lat=>Random.rand(22.598348..22.609292).round(6))
end

1.times do |ii|
  #模拟storm节点位置在深圳市区内
  Storm.create(:lng=>114.007133,:lat=>22.610463)
  Storm.create(:lng=>114.003504,:lat=>22.602569)
  Storm.create(:lng=>114.00495,:lat=>22.597703)
  Storm.create(:lng=>114.01122,:lat=>22.600239)
end

# 储存弹幕信息
Barrage.create(:info=>'init', :checked=>true)
=end
# 模拟无人船各项参数
Ocean.create

# 模拟航行计划状态各项参数
PlanStatus.create

# 模拟移动端和前端交互临时信息参数
Info.create(:lng=>114.004918, :lat=>22.60148, :checked=>true, :warning=>false)

#测试数据库生成
Test.create

#GPS模块相应数据库生成
GpsLocation.create
