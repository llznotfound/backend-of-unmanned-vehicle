class Ocean < ApplicationRecord
  def self.information
    ocean = self.first
    plan = PlanStatus.first
    {:speed => ocean.speed,
     :angle => ocean.angle,
     :communicate => ocean.communicate,
     :time => ocean.time,
     :battery => ocean.battery,
     :radius => ocean.radius,
     :ph => plan.ph,
     :conductivity => plan.conductivity,
     :turbidity => plan.turbidity,
     :oxygen => plan.oxygen,
     :temperature => plan.temperature,
     :voltage1 => plan.voltage1,
     :voltage2 => plan.voltage2,
     :lng => plan.lng,
     :lat => plan.lat}
  end
end
