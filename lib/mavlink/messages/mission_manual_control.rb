module MAVLink
    module Messages
      class MissionManualControl < Message
  
        def x
            @x ||= int16_t(0..1)
          end
    
          def y
            @y ||= int16_t(2..3)
          end
  
          def z
            @z ||= int16_t(4..5)
          end
  
          def r
            @r ||= int16_t(6..7)
          end
  
          def buttons
            @buttons ||= uint16_t(8..9)
          end
  
          def target
            @target ||= uint8_t(10..11)
          end
  
      end
    end
  end
  