# three responsibilities:
# - fetch Lichess puzzle data files
# - import Lichess puzzle data (*.json files) into the database
# - check that the puzzle files were loaded correctly

module LichessPuzzlesV1Importer
  PUZZLE_FILES = Rails.root.join("data/lichess-puzzles-v1/[0-9]*.json")
  # The total number of Lichess puzzles as of Oct 2020
  NUM_LICHESS_PUZZLES = 125262

  # downloads a .zip file of lichess v1 puzzles and unzips them into the data/ dir
  def self.fetch_puzzles_json
    # TODO download from https://github.com/linrock/blitz-tactics-puzzles
  end

  # Imports lichess puzzles from *.json files into the database.
  # Tries to map the puzzle_id columns in the database 1-to-1 to lichess puzzle ids.
  def self.import_puzzles_json
    if Puzzle.count > 0
      # TODO imports should be resumable
      "Can only import lichess puzzle files from an empty database"
      return
    end
    json_puzzle_files = Dir.glob(PUZZLE_FILES)
    # Expecting to load a json file with this lichess puzzle id next
    upcoming_lichess_puzzle_id = 1
    # Loads JSON files in order - 1.json 2.json 3.json 5.json 10.json ...
    sorted_json_puzzle_filenames = json_puzzle_files.sort_by do |filename|
      filename[/([0-9]+)\.json/, 1].to_i
    end
    sorted_json_puzzle_filenames.each do |json_puzzle_file|
      puzzle_json_data = JSON.parse(open(json_puzzle_file).read)
      # puts puzzle_json_data
      lichess_puzzle_id = puzzle_json_data["metadata"]["id"]
      if upcoming_lichess_puzzle_id == lichess_puzzle_id
        # Do nothing. We expected to see this lichess puzzle id
      elsif upcoming_lichess_puzzle_id < lichess_puzzle_id 
        # Check if we're resuming a previous import
        last_puzzle = Puzzle.order('id DESC').first
        last_puzzle_id = last_puzzle.puzzle_id.to_i
        if last_puzzle_id > upcoming_lichess_puzzle_id 
          upcoming_lichess_puzzle_id = last_puzzle_id
        end
        # We're missing a Lichess puzzle with this id
        # Create a dummy puzzle and destroy it
        while lichess_puzzle_id > upcoming_lichess_puzzle_id
          create_and_destroy_blank_puzzle
          upcoming_lichess_puzzle_id += 1
        end
      end
      # By now, the upcoming JSON data is from the expected lichess
      # puzzle id.
      ActiveRecord::Base.logger.silence do
        created_puzzle = Puzzle.create!({
          puzzle_id: lichess_puzzle_id,
          puzzle_data: puzzle_json_data["puzzle_data"],
          metadata: puzzle_json_data["metadata"],
          puzzle_data_hash: Puzzle.data_hash(puzzle_json_data)
        })
        puts "Created puzzle from Lichess puzzle #{lichess_puzzle_id}"
        upcoming_lichess_puzzle_id = lichess_puzzle_id + 1
        if Puzzle.order('id DESC').first.id != lichess_puzzle_id
          puts "Error matching puzzle ids with lichess puzzle ids"
          return
        end
      end
    end
    if sorted_json_puzzle_filenames == Puzzle.count
      puts "Successfully imported #{Puzzle.count} Lichess puzzles!"
    end
  end

  # Hack for matching puzzle_id values with lichess puzzle ids
  # since some of the lichess puzzles were deleted.
  def self.create_and_destroy_blank_puzzle
    p = Puzzle.create!({
      puzzle_id: "blank",
      puzzle_data_hash: 'blank',
      puzzle_data: { b: 0 }
    })
    p.destroy!
  end

  # Check to see if the lichess puzzles were loaded as expected
  # Each Puzzle.id exactly matches Lichess puzzle ids
  def self.check_db_puzzles
    if Puzzle.count != NUM_LICHESS_PUZZLES
      puts "Expected #{NUM_LICHESS_PUZZLES} puzzles. Got #{Puzzle.count}"
      return false
    end
    first_lichess_puzzle_id = Puzzle.order('id ASC').first.puzzle_id
    last_lichess_puzzle_id = Puzzle.order('id ASC').last.puzzle_id
    if first_lichess_puzzle_id != "1"
      puts "Didn't expect #{first_lichess_puzzle_id} to be the first puzzle"
      return false
    end
    if last_lichess_puzzle_id != "125272"
      puts "Didn't expect #{last_lichess_puzzle_id} to be the last puzzle"
      return false
    end
    puts "Found #{Puzzle.count} puzzles out of #{NUM_LICHESS_PUZZLES} expected Lichess puzzles"
    return true
  end
end