module MAVLink
  module Messages
    class SysStatus < Message

      def onboard_control_sensors_present
        @onboard_control_sensors_present ||= uint32_t(0..3)
      end

      def onboard_control_sensors_enabled
        @onboard_control_sensors_enabled ||= uint32_t(4..7)
      end

      def onboard_control_sensors_health
        @onboard_control_sensors_health ||= uint32_t(8..11)
      end

      # 0%..100%
      def load
        @load ||= (uint16_t(12..13) / 10.0)
      end

      # V
      def voltage_battery
        @voltage_battery ||= (uint16_t(14..15) / 1000.0)
      end

      # A (-1: not measured)
      def current_battery
        @current_battery ||= (int16_t(16..17) / 100.0)
      end

      # 0%..100% (bad packet %age)
      def drop_rate_comm
        @drop_rate_comm ||= (uint16_t(18..19) / 100)
      end

      def errors_comm
        @errors_comm ||= uint16_t(20..21)
      end

      def errors_count1
        @errors_count1 ||= uint16_t(22..23)
      end

      def errors_count2
        @errors_count2 ||= uint16_t(24..25)
      end

      def errors_count3
        @errors_count3 ||= uint16_t(26..27)
      end

      def errors_count4
        @errors_count4 ||= uint16_t(28..29)
      end

      # 0%..100% (-1: not measured)
      def battery_remaining
        @battery_remaining ||= uint8_t(30)
      end

    end
  end
end
