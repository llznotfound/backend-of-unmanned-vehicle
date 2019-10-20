module MAVLink
  module Messages
    class SendMissionRequest < SendMessage
      ID = 40
      LENGTH = 5
      CRC = 230

      def seq(num)
        @seq = uint16_t(num)
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
        super + @seq + @target_system + @target_component #+ @mission_type
      end

      def code
        inspect + cal_crc(CRC)
      end

    end
  end
end
