module MAVLink
    module Messages
      class SetMode < Message
  
        def custom_mode
          @custom_mode ||= uint32_t(0..3)
        end
  
        def target_system
          @target_system ||= uint8_t(4)
        end
  
        def base_mode
          @base_mode ||= uint8_t(5)
        end
  
      end
    end
  end