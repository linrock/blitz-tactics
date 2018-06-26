class DropLichessPuzzles < ActiveRecord::Migration[5.2]
  def change
    drop_table :lichess_puzzles do
    end
  end
end
