class CreateOceans < ActiveRecord::Migration[5.1]
  def change
    create_table :oceans do |t|
      t.float :speed, default: 0
      t.float :angle, default: 0
      t.integer :communicate, default: -50
      t.integer :time, default: 0
      t.integer :battery, default: 0
      t.float :radius, default: 0

      t.timestamps
    end
  end
end
