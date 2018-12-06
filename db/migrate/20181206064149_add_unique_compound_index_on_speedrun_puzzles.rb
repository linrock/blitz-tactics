class AddUniqueCompoundIndexOnSpeedrunPuzzles < ActiveRecord::Migration[5.2]
  def change
    add_index :speedrun_puzzles, [:speedrun_level_id, :puzzle_hash], unique: true
  end
end
