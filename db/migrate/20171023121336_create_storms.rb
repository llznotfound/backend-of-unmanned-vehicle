class CreateStorms < ActiveRecord::Migration[5.1]
  def change
    create_table :storms do |t|
      t.float :lng, default:121.437424
      t.float :lat, default:31.024824

      t.timestamps
    end
  end
end
