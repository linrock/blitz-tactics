class CreateRepetitionPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :repetition_puzzles do |t|
      t.integer :repetition_level_id, null: false
      t.jsonb :data, null: false
      t.string :puzzle_hash, null: false
      t.timestamps null: false
    end
    add_index :repetition_puzzles, :repetition_level_id
    add_index :repetition_puzzles, :puzzle_hash, unique: true
  end
end
