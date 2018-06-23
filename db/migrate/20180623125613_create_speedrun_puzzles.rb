class CreateSpeedrunPuzzles < ActiveRecord::Migration[5.2]
  def change
    create_table :speedrun_puzzles do |t|
      t.integer :speedrun_level_id, null: false
      t.integer :new_lichess_puzzle_id, null: false
      t.timestamps null: false
    end
    add_index :speedrun_puzzles, :speedrun_level_id
  end
end
