class CreateInfinityLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :infinity_levels do |t|
      t.string :difficulty, null: false
      t.timestamps null: false
    end
    add_index :infinity_levels, :difficulty, unique: true
  end
end
