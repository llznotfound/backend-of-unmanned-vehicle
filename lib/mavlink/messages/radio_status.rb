module MAVLink
  module Messages
    class RadioStatus < Message

      def rxerrors
        @rxerrors ||= uint16_t(0..1)
      end

      def fixed
        @fixed ||= uint16_t(2..3)
      end

      def rssi
        @rssi ||= uint8_t(4)
      end

      def remrssi
        @remrssi ||= uint8_t(5)
      end

      def txbuf
        @txbuf ||= uint8_t(6)
      end

      def noise
        @noise ||= uint8_t(7)
      end

      def remnoise
        @remnoise ||= uint8_t(8)
      end

    end
  end
end
