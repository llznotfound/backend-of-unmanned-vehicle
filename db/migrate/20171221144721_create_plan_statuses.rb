class CreatePlanStatuses < ActiveRecord::Migration[5.1]
  def change
    create_table :plan_statuses do |t|
      t.float :ph, default: 7
      t.float :conductivity, default: 3
      t.float :turbidity, default: 0
      t.float :oxygen, default: 4
      t.float :temperature, default: 20
      t.float :voltage1, default: 24
      t.float :voltage2, default: 24
      t.float :lng, default:122.445967
      t.float :lat, default:31.032097

      t.timestamps
    end
  end
end
