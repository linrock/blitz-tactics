class RemoveUniqueIndexOnSpeedrunPuzzles < ActiveRecord::Migration[5.2]
  def change
    remove_index :speedrun_puzzles, :puzzle_hash
  end
end
