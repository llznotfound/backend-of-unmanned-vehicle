class PlanStatus < ApplicationRecord
  def self.information
    plan = self.first
    {:ph => plan.ph,
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
