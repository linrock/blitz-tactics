class CreateSpeedrunPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :speedrun_puzzles do |t|
      t.integer :speedrun_level_id, null: false
      t.jsonb :data, null: false
      t.string :puzzle_hash, null: false
      t.timestamps null: false
    end
    add_index :speedrun_puzzles, :speedrun_level_id, order: { id: :asc }
    add_index :speedrun_puzzles, :puzzle_hash, unique: true
  end
end
