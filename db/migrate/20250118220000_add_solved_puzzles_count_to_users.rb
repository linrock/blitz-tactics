class AddSolvedPuzzlesCountToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :solved_puzzles_count, :integer, default: 0, null: false
    add_index :users, :solved_puzzles_count
  end
end
