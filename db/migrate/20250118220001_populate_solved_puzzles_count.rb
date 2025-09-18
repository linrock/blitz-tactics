class PopulateSolvedPuzzlesCount < ActiveRecord::Migration[7.1]
  def up
    # Reset the counter cache for all users
    User.reset_counters(User.all.pluck(:id), :solved_puzzles)
  end

  def down
    # Set all counts back to 0
    User.update_all(solved_puzzles_count: 0)
  end
end
