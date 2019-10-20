module MAVLink
  module Messages
    class MissionAck < Message

      def target_system
        @target_system ||= uint8_t(0)
      end

      def target_component
        @target_component ||= uint8_t(1)
      end

      def type
        @type ||= uint8_t(2)
      end

      def mission_type
        @mission_type ||= uint8_t(3)
      end

    end
  end
end
