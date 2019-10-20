module MAVLink
  module Messages
    class SendMissionRequestList < SendMessage
      ID = 43
      LENGTH = 3
      CRC = 132

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
        super + @target_system + @target_component #+ @mission_type
      end

      def code
        inspect + cal_crc(CRC)
      end

    end
  end
end
