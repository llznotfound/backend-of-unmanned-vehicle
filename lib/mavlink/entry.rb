module MAVLink
  class Entry

    attr_reader :header, :payload, :crc

    def initialize(header, payload, raw_crc)
      @header = header
      @payload = payload
      @crc = to_crc(raw_crc)
    end

    private

    def to_time(raw)
      (raw[0..3].unpack('L>')[0] << 32) | raw[4..7].unpack('L>')[0]
    end

    def to_crc(raw)
      raw.unpack('S>')[0]
    end

  end
end
