class CreateInfos < ActiveRecord::Migration[5.1]
  def change
    create_table :infos do |t|
      t.float :lng
      t.float :lat
      t.boolean :checked, default: true  #语音输入地理位置信息是否有效标志
      t.boolean :warning, default: false  #警告模式提醒

      t.timestamps
    end
  end
end
