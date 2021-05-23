class PuzzleSet < ActiveRecord::Base
  belongs_to :user
  has_many :lichess_v2_puzzles_puzzle_sets
  has_many :lichess_v2_puzzles, through: :lichess_v2_puzzles_puzzle_sets

  PUZZLE_LIMIT = 25_000  # arbitrary limit on # of puzzles per puzzle set

  def textarea_puzzle_ids
    lichess_v2_puzzles.pluck(:puzzle_id).join("\n")
  end

  def num_puzzles
    @num_puzzles ||= lichess_v2_puzzles.count
  end

  # TODO fix performance problems
  def random_level
    if num_puzzles < 10
      return lichess_v2_puzzles.map(&:bt_puzzle_data).shuffle
    end
    sorted_puzzle_ids = lichess_v2_puzzles.order('rating ASC').pluck(:id)
    bucket_size = (num_puzzles / 10.0).ceil
    serve_puzzle_ids = []
    sorted_puzzle_ids.each_slice(bucket_size).each do |bucket|
      serve_puzzle_ids.push(*bucket.shuffle.take(10))
    end
    LichessV2Puzzle.find_by_sorted(serve_puzzle_ids).map(&:bt_puzzle_data)
  end
end