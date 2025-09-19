class AddCreatedAtIndexToSolvedPuzzles < ActiveRecord::Migration[5.1]
  def change
    # Add composite index for efficient user-specific and date range queries
    # This will significantly improve performance for:
    # - User profile queries (user_id first for selectivity)
    # - unique_puzzles_solved_on_day queries (date range with grouping)
    # - admin analytics queries by date
    # - Recent activity feeds and daily stats
    add_index :solved_puzzles, [:user_id, :created_at], 
              name: 'index_solved_puzzles_on_user_id_and_created_at'
  end
end
