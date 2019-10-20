module MAVLink
  module Messages
    class SendMissionAck < SendMessage
      ID = 47
      LENGTH = 4
      CRC = 153

      def target_system(num)
        @target_system = uint8_t(num)
      end

      def target_component(num)
        @target_component = uint8_t(num)
      end

      def type(num)
        @type = uint8_t(num)
      end

      def mission_type(num)
        @mission_type = uint8_t(num)
      end

      def inspect
        super + @target_system + @target_component + @type #+ @mission_type
      end

      def code
        inspect + cal_crc(CRC)
      end

    end
  end
end