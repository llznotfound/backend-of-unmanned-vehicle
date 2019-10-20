class CreateRoutes < ActiveRecord::Migration[5.1]
  def change
    create_table :routes do |t|
      t.float :lng, default:121.910985
      t.float :lat, default:30.880742

      t.timestamps
    end
  end
end
