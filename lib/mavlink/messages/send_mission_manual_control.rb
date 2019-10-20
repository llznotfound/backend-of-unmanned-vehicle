module MAVLink
    module Messages
      class SendMissionManualControl < SendMessage
        ID = 69
        LENGTH = 11
        CRC = 243
  
        def x(num)
          @x = int16_t(num)
        end
  
        def y(num)
          @y = int16_t(num)
        end

        def z(num)
          @z = int16_t(num)
        end

        def r(num)
          @r = int16_t(num)
        end

        def buttons(num)
          @buttons = uint16_t(num)
        end

        def target(num)
          @target = uint8_t(num)
        end
  
        def inspect
          super + @x + @y + @z + @r + @buttons + @target
        end
  
        def code
          inspect + cal_crc(CRC)
        end
  
      end
    end
  end
  