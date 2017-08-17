class LichessPuzzle < ActiveRecord::Base

  def self.load_from_json_files!
    files = Dir.glob(Rails.root.join("data/lichess/*.json"))
    files.sort_by {|path| path[/\d+/].to_i }.each do |file|
      puzzle_id = file[/(\d+)\.json/, 1].to_i
      next if LichessPuzzle.exists?(:puzzle_id => puzzle_id)
      data = open(file).read.strip
      begin
        LichessPuzzle.create!(:puzzle_id => puzzle_id, :data => JSON.parse(data))
      rescue
        `rm #{file}`
      end
    end
    nil
  end

  def self.from_puzzle_ids(puzzle_ids)
    puzzles = []
    puzzle_ids.each {|id| puzzles << find_by(puzzle_id: id) }
    puzzles
  end

  def self.rating_gt(min_rating)
    where("CAST(data->'puzzle'->>'rating' AS INT) > ?", min_rating)
  end

  def self.rating_lt(max_rating)
    where("CAST(data->'puzzle'->>'rating' AS INT) < ?", max_rating)
  end

  def self.attempts_gt(n_attempts)
    where("CAST(data->'puzzle'->>'attempts' AS INT) > ?", n_attempts)
  end

  def self.vote_gt(votes)
    where("CAST(data->'puzzle'->>'vote' AS INT) > ?", votes)
  end

  def self.white_to_move
    where("data->'puzzle'->>'color' = 'white'")
  end

  def self.n_pieces_query
    "char_length(
       regexp_replace(
       split_part(data->'puzzle'->>'fen', ' ', 1),
                  '[^a-zA-Z]', '', 'g')
     )"
  end

  def self.n_pieces_eq(n)
    where("#{n_pieces_query} = ?", n)
  end

  def self.n_pieces_lt(n)
    where("#{n_pieces_query} < ?", n)
  end

  def self.n_pieces_gt(n)
    where("#{n_pieces_query} > ?", n)
  end

  def rating
    data.dig("puzzle", "rating")
  end

  # New minimal data format
  #
  def simplified_data
    data["puzzle"].slice("fen", "initialMove", "lines")
  end

end
