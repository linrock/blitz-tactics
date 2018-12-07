class CreateCountdownPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :countdown_puzzles do |t|
      t.integer :countdown_level_id, null: false
      t.jsonb :data, null: false
      t.string :puzzle_hash, null: false
      t.timestamps null: false
    end
    add_index :countdown_puzzles, :countdown_level_id, order: { id: :asc }
    add_index :countdown_puzzles,
      [:countdown_level_id, :puzzle_hash], unique: true
  end
end
