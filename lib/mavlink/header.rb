module MAVLink
  #接收消息包的头部解析
  class Header

    attr_reader :magic, :length, :sequence, :system, :component, :id

    def initialize(raw_header)
      @magic = raw_header[0].unpack('C')[0]
      @length = raw_header[1].unpack('C')[0]
      @sequence = raw_header[2].unpack('C')[0]
      @system = raw_header[3].unpack('C')[0]
      @component = raw_header[4].unpack('C')[0]
      @id = raw_header[5].unpack('C')[0]
    end

  end

  #发送消息包的头部生成
  class SendHeader

    attr_reader :magic, :length, :sequence, :system, :component, :id

    def initialize(magic, length, sequence, system, component, id)
      @magic = [magic].pack('C')
      @length = [length].pack('C')
      @sequence = [sequence].pack('C')
      @system = [system].pack('C')
      @component = [component].pack('C')
      @id = [id].pack('C')
    end

    def inspect
      @magic + @length + @sequence + @system + @component + @id
    end
  end
end
