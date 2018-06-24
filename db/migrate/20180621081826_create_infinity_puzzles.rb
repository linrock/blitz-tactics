class CreateInfinityPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :infinity_puzzles do |t|
      t.integer :infinity_level_id, null: false
      t.jsonb :data, null: false
      t.string :puzzle_hash, null: false
      t.timestamps null: false
    end
    add_index :infinity_puzzles, :infinity_level_id, order: { id: :asc }
    add_index :infinity_puzzles, :puzzle_hash, unique: true
  end
end
