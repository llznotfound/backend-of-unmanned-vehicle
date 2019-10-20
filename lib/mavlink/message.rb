module MAVLink
  #解析接收到的消息包
  class Message

    def initialize(entry)
      @entry = entry
    end

    def id
      @entry.header.id
    end

    def crc
      @entry.crc
    end

    protected

    def float(range)
      unpack(range, 'e')
    end

    def int8_t(range)
      unpack(range, 'c')
    end

    def uint8_t(range)
      unpack(range, 'C')
    end

    def int16_t(range)
      unpack(range, 's<')
    end

    def uint16_t(range)
      unpack(range, 'S<')
    end

    def int32_t(range)
      unpack(range, 'l<')
    end

    def uint32_t(range)
      unpack(range, 'L<')
    end

    def uint64_t(range)
      unpack(range, 'Q<')
    end

    def string(range)
      unpack(range, 'Z*')
    end

    private

    def payload
      @entry.payload
    end

    def unpack(range, format, index = 0)
      if payload[range]
        payload[range].unpack(format)[index]
      else
        #字段不存在时返回默认解析值0
        0
      end
    end

  end

  class TimedMessageMilli < Message

    def time_boot_ms
      @time_boot_ms ||= uint32_t(0..3)
    end

  end

  class TimedMessageMicro < Message

    def time_usec
      @time_usec ||= uint64_t(0..7)
    end

  end

  #生成发送的消息包
  class SendMessage

    def initialize(header)
      @header = header
    end

    def inspect
      @header.inspect
    end

    def cal_crc(crc)
      #CRC-16-MCRF4XX是与python文件中x25crc相同的校验方法
      [CRC.crc('CRC-16-MCRF4XX', inspect[1..-1] + [crc].pack('C'))].pack('S')
    end

    private

    def float(num)
      [num].pack('e')
    end

    def int8_t(num)
      [num].pack('c')
    end

    def uint8_t(num)
      [num].pack('C')
    end

    def int16_t(num)
      [num].pack('s<')
    end

    def uint16_t(num)
      [num].pack('S<')
    end

    def int32_t(num)
      [num].pack('l<')
    end

    def uint32_t(num)
      [num].pack('L<')
    end

    def uint64_t(num)
      [num].pack('Q<')
    end

    def string(num)
      [num].pack('Z*')
    end
  end
end
