module MAVLink
  module Messages
    class SendSetMode < SendMessage
      ID = 11
      LENGTH = 6
      CRC = 89

      def custom_mode(num)
        @custom_mode = uint32_t(num)
      end

      def target_system(num)
        @target_system = uint8_t(num)
      end

      def base_mode(num)
        @base_mode = uint8_t(num)
      end

      def inspect
        super + @custom_mode + @target_system + @base_mode
      end

      def code
        inspect + cal_crc(CRC)
      end

    end
  end
end
