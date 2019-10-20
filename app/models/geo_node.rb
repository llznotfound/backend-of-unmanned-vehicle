class GeoNode < ApplicationRecord

  #模拟节点的运动
  def update_location
    if self.id<=250 && self.id>125
      self.lng += (Random.rand(0.0008) - 0.0004)
      self.lat += (Random.rand(0.0008) - 0.0004)
    elsif self.id>=250 && self.id<=500
      self.lng += (Random.rand(0.0004) - 0.0002)
      self.lat += (Random.rand(0.0004) - 0.0002)
    end
    self.save
  end

  #重新生成节点位置，防止跑偏
  def reset_location
    self.update(:lng=>Random.rand(114.001163..114.012195).round(6),:lat=>Random.rand(22.598348..22.609292).round(6))
  end

  class<<self
    def move
      self.all.map { |node|
        node.update_location
      }
    end

    def reset
      self.all.map {|node|
        node.reset_location
      }
    end
  end
end
