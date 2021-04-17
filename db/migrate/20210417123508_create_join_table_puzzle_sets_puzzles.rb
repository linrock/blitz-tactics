class CreateJoinTablePuzzleSetsPuzzles < ActiveRecord::Migration[6.1]
  def change
    create_table :puzzle_sets_puzzles, id: false do |t|
      t.integer :puzzle_set_id, null: false
      t.string :puzzle_id, null: false
    end
    add_index :puzzle_sets_puzzles, [:puzzle_set_id, :puzzle_id], unique: true
    add_index :puzzle_sets_puzzles, [:puzzle_id, :puzzle_set_id], unique: true
  end
end
