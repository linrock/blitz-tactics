# Tracks unique chess puzzles solved by users across all game modes

class SolvedPuzzle < ActiveRecord::Base
  belongs_to :user

  validates :puzzle_id, presence: true
  validates :user_id, presence: true
  validates :puzzle_id, uniqueness: { scope: :user_id }

  # Simple tracking - just update the timestamp when a puzzle is solved
  def self.track_solve(user_id, puzzle_id)
    solved_puzzle = find_or_initialize_by(user_id: user_id, puzzle_id: puzzle_id)
    if solved_puzzle.persisted?
      solved_puzzle.touch  # Updates updated_at timestamp for existing records
    else
      solved_puzzle.save!  # Create new record
    end
    solved_puzzle
  end

  # Bulk insert/update solved puzzles for a user (minimizes database requests)
  def self.bulk_create_for_user(user_id, puzzle_ids)
    return if puzzle_ids.blank?

    # Get existing puzzles for this user
    existing_records = where(user_id: user_id, puzzle_id: puzzle_ids)
    existing_puzzle_ids = existing_records.pluck(:puzzle_id)
    new_puzzle_ids = puzzle_ids - existing_puzzle_ids

    # Update timestamps for existing puzzles
    if existing_puzzle_ids.any?
      existing_records.update_all(updated_at: Time.current)
    end

    # Insert new puzzles
    if new_puzzle_ids.any?
      records = new_puzzle_ids.map do |puzzle_id|
        {
          user_id: user_id,
          puzzle_id: puzzle_id,
          created_at: Time.current,
          updated_at: Time.current
        }
      end
      insert_all(records)
    end
  end

  # Get count of unique puzzles solved by a user
  def self.count_for_user(user_id)
    where(user_id: user_id).count
  end

  # Get most recently solved puzzles for a user
  def self.recently_solved_for_user(user_id, limit = 10)
    where(user_id: user_id).order(updated_at: :desc).limit(limit)
  end

  # Get recent puzzles - simple version using existing fields
  def self.recent_with_details(user_id, limit = 10)
    where(user_id: user_id)
      .order(updated_at: :desc)
      .limit(limit)
      .map do |solved_puzzle|
        {
          puzzle_id: solved_puzzle.puzzle_id,
          solved_at: solved_puzzle.updated_at
        }
      end
  end

  # Get puzzles first solved by a user on a specific date
  def self.first_solved_on(user_id, date)
    where(user_id: user_id)
      .where(created_at: date.beginning_of_day..date.end_of_day)
      .order(:created_at)
  end
end
