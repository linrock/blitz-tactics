# fetch Lichess puzzle data files (compressed .csv file):
# LichessV2PuzzleImporter.new.fetch_csv
#
# import Lichess puzzle data into the database:
# LichessV2PuzzleImporter.new.import_from_csv

class LichessV2PuzzleImporter
  CSV_URL = "https://database.lichess.org/lichess_db_puzzle.csv.bz2"
  OUT_FILE = Rails.root.join("data/lichess_db_puzzle.csv.bz2")
  CSV_FILE = Rails.root.join("data/lichess_db_puzzle.csv")

  # the number of rows to import per db transaction
  BATCH_SIZE = 10_000

  # skip this number of rows in the CSV for resuming imports
  SKIP_NUM_ROWS = 0

  def initialize
    # track lichess puzzle ids already in the DB
    @db_puzzle_ids = Set.new
  end

  # Fetches and unzips v2 puzzles CSV
  def fetch_csv
    `wget '#{CSV_URL}' -O #{OUT_FILE}`
    `bunzip2 -f #{OUT_FILE}`
    nil
  end

  # Import all puzzles from a CSV file
  # https://database.lichess.org/#puzzles
  def import_from_csv
    num_rows = `wc -l "#{CSV_FILE}"`.strip.split(' ')[0].to_i
    @db_puzzle_ids = LichessV2Puzzle.pluck(:puzzle_id).to_set
    i = 0
    open(CSV_FILE, "r") do |f|
      ActiveRecord::Base.logger.silence do
        while !f.eof?
          ActiveRecord::Base.transaction do
            BATCH_SIZE.times do
              i += 1
              if SKIP_NUM_ROWS >= i
                f.readline
                next
              end
              result = import_csv_next_row(f)
              percent_done = (i * 100.0 / num_rows).floor
              if result
                puts "[#{percent_done}%] imported lichess_db_puzzle.csv row #{i}: #{result}"
              else
                puts "[#{percent_done}%] skipped lichess_db_puzzle.csv row #{i}"
              end
            end
          end
        end
      end
    end
  end

  # Attempts to import a puzzle from a single row of the CSV file.
  # File format docs at: https://database.lichess.org/#puzzles
  # PuzzleId,FEN,Moves,Rating,RatingDeviation,Popularity,NbPlays,Themes,GameUrl
  def import_csv_next_row(f)
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

    # special-case hacks
    if lichess_puzzle_id == 'gtWql'
      puzzle_themes -= ["mate", "mateIn2"] # fix incorrect tags
    end

    # Update or insert the puzzle into the db
    if @db_puzzle_ids.include?(lichess_puzzle_id)
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
    lichess_puzzle_id
  end
end
