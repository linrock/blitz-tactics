class PopulateSolvedPuzzlesCount < ActiveRecord::Migration[7.1]
  def up
    # Manually populate the counter cache for all users
    User.find_each do |user|
      count = user.solved_puzzles.count
      user.update_column(:solved_puzzles_count, count)
    end
  end

  def down
    # Set all counts back to 0
    User.update_all(solved_puzzles_count: 0)
  end
end
