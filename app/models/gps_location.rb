class GpsLocation < ApplicationRecord
  def self.info
    gps = self.first
    {:gps_lng => gps.lng,
     :gps_lat => gps.lat,
     :gps_heading => gps.heading}
  end
end
