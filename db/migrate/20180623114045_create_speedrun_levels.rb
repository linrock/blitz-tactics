class CreateSpeedrunLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :speedrun_levels do |t|
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
