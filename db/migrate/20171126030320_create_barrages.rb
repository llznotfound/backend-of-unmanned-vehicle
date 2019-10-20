class CreateBarrages < ActiveRecord::Migration[5.1]
  def change
    create_table :barrages do |t|
      t.string :info
      t.boolean :checked

      t.timestamps
    end
  end
end
