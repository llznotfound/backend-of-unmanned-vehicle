class GeoController < ApplicationController
  def information
    mode = params[:mode] || ''
    data = GeoNode.all.map do |node|
      info = Hash.new
      info[:id]=node.id
      info[:geo] = [node.lng, node.lat]
      info[:space] = Random.rand(2..128)
      info[:compute] = Random.rand(2.0..4.0).round(2)
      info[:channel] = -Random.rand(50..120)
      if mode == 'iotTwo'
        info[:temperature] = Random.rand(20..40)
        info[:speed] = Random.rand(0.0..10.0).round(1)
        info[:server] = Random.rand(0..3)
      end
      info
    end
    data = {data:{'payloads':data}}
    render json:data, callback: params['callback']
  end

  def storm
    nodes = FogComputingNode.all_alive
    data = Storm.all.map do |node|
      info = Hash.new
      info[:id]=node.id
      info[:geo] = {lng:node.lng, lat:node.lat}
      info[:process] = Random.rand(200..300)
      info[:memory] = Random.rand(300..400)
      info[:overload] = Random.rand(100)
      info[:bandwidth] = Random.rand(100)
      info[:alive] = nodes[node.id-1]
      info
    end
    data = {data:{'payloads':data, 'alive':(nodes.select {|x| x}).length}}
    render json:data, callback: params['callback']
  end

  def update
    info = params[:info]
    if !info
      return
    end
    Barrage.first.update(:info=>info, :checked=>false)
  end

  def get
    if Barrage.first.checked
      data = ''
    else
      data = Barrage.first.info
      Barrage.first.update(:checked=>true)
    end
    render json:{data:data}, callback: params['callback']
  end
end
