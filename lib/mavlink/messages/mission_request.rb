module MAVLink
  module Messages
    class MissionRequest < Message

      def seq
        @seq ||= uint16_t(0..1)
      end

      def target_system
        @target_system ||= uint8_t(2)
      end

      def target_component
        @target_component ||= uint8_t(3)
      end

      def mission_type
        @mission_type ||= uint8_t(4)
      end

    end
  end
end