class AddGameModeToSolvedPuzzles < ActiveRecord::Migration[8.0]
  def change
    add_column :solved_puzzles, :game_mode, :string
  end
end
