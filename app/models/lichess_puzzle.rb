class LichessPuzzle < ActiveRecord::Base

  def self.load_from_json_files!
    Dir.glob(Rails.root.join("data/lichess/*.json")).each do |file|
      puzzle_id = file[/(\d+)\.json/, 1].to_i
      next if LichessPuzzle.exists?(:puzzle_id => puzzle_id)
      data = open(file).read.strip
      begin
        LichessPuzzle.create!(:puzzle_id => puzzle_id, :data => data)
      rescue
        `rm #{file}`
      end
    end
    nil
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

end
