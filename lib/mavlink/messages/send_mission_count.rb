module MAVLink
  module Messages
    class SendMissionCount < SendMessage
      ID = 44
      LENGTH = 5
      CRC = 221

      def count(num)
        @count = uint16_t(num)
      end

      def target_system(num)
        @target_system = uint8_t(num)
      end

      def target_component(num)
        @target_component = uint8_t(num)
      end

      def mission_type(num)
        @mission_type = uint8_t(num)
      end

      def inspect
        super + @count + @target_system + @target_component #+ @mission_type
      end

      def code
        inspect + cal_crc(CRC)
      end

    end
  end
end
