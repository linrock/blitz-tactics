# three responsibilities:
# - fetch Lichess puzzle data files
# - import Lichess puzzle data (*.json files) into the database
# - check that the puzzle files were loaded correctly

module LichessPuzzlesV2Importer
  CSV_URL = "https://database.lichess.org/lichess_db_puzzle.csv.bz2"

  # Fetches and unzips v2 puzzles csv
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

    # Update the puzzle in the db
    if LichessPuzzle.exists?(puzzle_id: lichess_puzzle_id)
      puzzle = LichessPuzzle.find_by(puzzle_id: lichess_puzzle_id)
      throw "Unexpected change in #{initial_fen}" if puzzle.initial_fen != initial_fen
      throw "Unexpected change in #{move_sequence_uci}" if puzzle.move_sequence_uci != move_sequence_uci
    else
      puzzle = LichessPuzzle.new(puzzle_id: lichess_puzzle_id)
    end
    moves_uci = moves_uci.split(/\s+/)
    puzzle.initial_fen = initial_fen
    puzzle.moves_uci = moves_uci
    puzzle.rating = rating
    puzzle.rating_deviation = rating_deviation
    puzzle.popularity = popularity
    puzzle.num_plays = num_plays
    puzzle.game_url = game_url
    return unless puzzle.changed?
    puzzle.save!

    # Associates puzzle themes with puzzles
    puzzle_themes.split(/\s+/).each do |theme|
      theme = PuzzleTheme.find_or_create_by(name: theme)
      if theme.lichess_puzzles.exists?(puzzle_id: puzzle.puzzle_id)
        theme.lichess_puzzles << puzzle
      else
        # Delete a theme if it was removed
        theme.lichess_puzzles.delete(puzzle)
      end
    end
  end

  extend self
end