class CreateJoinTablePuzzleSetsPuzzles < ActiveRecord::Migration[6.1]
  def change
    create_join_table :puzzle_sets, :puzzles do |t|
      t.index [:puzzle_set_id, :puzzle_id], unique: true
      t.index [:puzzle_id, :puzzle_set_id], unique: true
    end
  end
end
