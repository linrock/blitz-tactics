class CreateJoinTableLichessPuzzlesCategories < ActiveRecord::Migration[6.1]
  def change
    create_join_table :lichess_puzzles, :puzzle_categories do |t|
      t.index [:lichess_puzzle_id, :puzzle_category_id], name: "idx_lichess_puzzle_categories"
      t.index [:puzzle_category_id, :lichess_puzzle_id], name: "idx_category_lichess_puzzles"
    end
  end
end
