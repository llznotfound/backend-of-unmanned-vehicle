module MAVLink
  module Messages
    class SendMissionItem < SendMessage
      ID = 39
      LENGTH = 38
      CRC = 254

      def param1(num)
        @param1 = float(num)
      end

      def param2(num)
        @param2 = float(num)
      end

      def param3(num)
        @param3 = float(num)
      end

      def param4(num)
        @param4 = float(num)
      end

      def x(num)
        @x = float(num)
      end

      def y(num)
        @y = float(num)
      end

      def z(num)
        @z = float(num)
      end

      def seq(num)
        @seq = uint16_t(num)
      end

      def command(num)
        @command = uint16_t(num)
      end

      def target_system(num)
        @target_system = uint8_t(num)
      end

      def target_component(num)
        @target_component = uint8_t(num)
      end

      def frame(num)
        @frame = uint8_t(num)
      end

      def current(num)
        @current = uint8_t(num)
      end

      def autocontinue(num)
        @autocontinue = uint8_t(num)
      end

      def mission_type(num)
        @mission_type = uint8_t(num)
      end

      def inspect
        super + @param1 + @param2 + @param3 + @param4 + @x + @y + @z +
            @seq + @command + @target_system + @target_component + @frame + @current +
            @autocontinue #+ @mission_type
      end

      def code
        inspect + cal_crc(CRC)
      end

    end
  end
end
