class CreateTests < ActiveRecord::Migration[5.1]
  def change
    create_table :tests do |t|
      t.float :temperature, default: 20
      t.float :ph, default: 7
      t.float :conductivity, default: 3
      t.float :turbidity, default: 5
      t.float :oxygen, default: 5
      t.float :lng, default:121.910985
      t.float :lat, default:30.880742

      t.timestamps
    end
  end
end
