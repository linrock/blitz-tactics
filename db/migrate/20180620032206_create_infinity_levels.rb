class CreateInfinityLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :infinity_levels do |t|
      t.string :difficulty, null: false
      t.jsonb :puzzle_id_array, null: false, default: []
      t.jsonb :puzzle_id_map, null: false, default: {}
      t.timestamps null: false
    end
    add_index :infinity_levels, :difficulty, unique: true
  end
end
