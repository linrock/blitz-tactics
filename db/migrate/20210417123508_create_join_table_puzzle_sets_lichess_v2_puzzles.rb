class CreateJoinTablePuzzleSetsLichessV2Puzzles < ActiveRecord::Migration[6.1]
  def change
    create_join_table :puzzle_sets, :lichess_v2_puzzles do |t|
      t.index :puzzle_set_id
      t.index :lichess_v2_puzzle_id
    end
  end
end
