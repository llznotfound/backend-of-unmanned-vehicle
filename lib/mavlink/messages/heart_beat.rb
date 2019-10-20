module MAVLink
  module Messages
    class HeartBeat < Message

      def custom_mode
        @custom_mode ||= uint32_t(0..3)
      end

      def type
        @type ||= uint8_t(4)
      end

      def autopilot
        @autopilot ||= uint8_t(5)
      end

      def base_mode
        @base_mode ||= uint8_t(6)
      end

      def system_status
        @system_status ||= uint8_t(7)
      end

      def mavlink_version
        @mavlink_version ||= uint8_t(8)
      end

    end
  end
end
