class CreateGpsLocations < ActiveRecord::Migration[5.1]
  def change
    create_table :gps_locations do |t|
      t.float :lng, default: 0
      t.float :lat, default: 0
      t.float :heading, default: 0

      t.timestamps
    end
  end
end
