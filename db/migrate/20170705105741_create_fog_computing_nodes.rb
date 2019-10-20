class CreateFogComputingNodes < ActiveRecord::Migration[5.1]
  def change
    create_table :fog_computing_nodes do |t|

      t.timestamps
    end
  end
end
