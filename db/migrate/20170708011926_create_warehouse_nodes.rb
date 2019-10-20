class CreateWarehouseNodes < ActiveRecord::Migration[5.1]
  def change
    create_table :warehouse_nodes do |t|

      t.timestamps
    end
  end
end
