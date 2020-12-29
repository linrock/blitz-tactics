class CreateJoinTableLichessPuzzlesThemes < ActiveRecord::Migration[6.1]
  def change
    create_join_table :lichess_puzzles, :puzzle_themes do |t|
      t.index [:lichess_puzzle_id, :puzzle_theme_id], name: "idx_lichess_puzzle_puzzle_themes"
      t.index [:puzzle_theme_id, :lichess_puzzle_id], name: "idx_puzzle_theme_lichess_puzzles"
    end
  end
end
