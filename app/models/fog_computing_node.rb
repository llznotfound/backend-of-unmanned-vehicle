class FogComputingNode < ApplicationRecord

  # 判断节点是否还活着
  # @return [TrueClass/FalseClass]
  def alive?
    (Time.now - self.updated_at) < 5.seconds
  end

  class << self

    def all_alive
      self.all.map do |node|
        node.alive?
      end
    end

    # 更新updated_at字段，用作心跳
    # @param [Fixnum] index
    # @return [nil]
    def update(index)
      node = self.find_by(id: index)
      node.update(updated_at: Time.now) if node
    end
  end
end
