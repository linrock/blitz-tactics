# three responsibilities:
# - fetch Lichess puzzle data files (compressed .csv file)
# - import Lichess puzzle data into the database
# - check that the puzzle files were loaded correctly

module LichessPuzzlesV2Importer
  CSV_URL = "https://database.lichess.org/lichess_db_puzzle.csv.bz2"

  # Fetches and unzips v2 puzzles CSV
  def fetch_csv
    `wget '#{CSV_URL}' -O #{Rails.root.join("data/lichess_db_puzzle.csv.bz2")}`
    `bunzip2 -f #{Rails.root.join("data/lichess_db_puzzle.csv.bz2")}`
    nil
  end

  # Import all puzzles from a CSV file
  # https://database.lichess.org/#puzzles
  def import_from_csv
    i = 0
    open(Rails.root.join("data/lichess_db_puzzle.csv"), "r") do |f|
      ActiveRecord::Base.logger.silence do
        while !f.eof?
          ActiveRecord::Base.transaction do
            1000.times do
              i += 1
              import_csv_row(f)
              puts "Imported puzzle #{i}"
            end
          end
        end
      end
    end
  end

  # Attempts to import a puzzle from a single row of the CSV file
  def import_csv_row(f)
    return if f.eof?
    # Read a row of the CSV
    lichess_puzzle_id,
    initial_fen,
    moves_uci,
    rating,
    rating_deviation,
    popularity,
    num_plays,
    puzzle_themes,
    game_url = f.readline.strip.split(",")
    # convert space-delimited fields to arrays
    moves_uci = moves_uci.split(/\s+/)
    puzzle_themes = puzzle_themes.split(/\s+/)

    # Update or insert the puzzle into the db
    if LichessV2Puzzle.exists?(puzzle_id: lichess_puzzle_id)
      puzzle = LichessV2Puzzle.find_by(puzzle_id: lichess_puzzle_id)
      throw "Unexpected change in #{initial_fen}" if puzzle.initial_fen != initial_fen
      throw "Unexpected change in #{moves_uci}" if puzzle.moves_uci != moves_uci
      throw "Unexpected change in #{game_url}" if puzzle.game_url != game_url
    else
      puzzle = LichessV2Puzzle.new(puzzle_id: lichess_puzzle_id)
    end
    puzzle.initial_fen = initial_fen
    puzzle.moves_uci = moves_uci
    puzzle.rating = rating
    puzzle.rating_deviation = rating_deviation
    puzzle.popularity = popularity
    puzzle.num_plays = num_plays
    puzzle.themes = puzzle_themes
    puzzle.game_url = game_url
    return unless puzzle.changed?
    puzzle.save!
  end

  extend self
end
