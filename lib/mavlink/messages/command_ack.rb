module MAVLink
  module Messages
    class CommandAck < Message

      def command
        @command ||= uint16_t(0..1)
      end

      def result
        @result ||= uint8_t(2)
      end

      def progress
        @progress ||= uint8_t(3)
      end

      def result_param2
        @result_param2 ||= int32_t(4..7)
      end

      def target_system
        @target_system ||= uint8_t(8)
      end

      def target_component
        @target_component ||= uint8_t(9)
      end

    end
  end
end
