class Puzzle < ActiveRecord::Base
  # Each puzzle is uniquely hashed based on their puzzle data
  validates :puzzle_data_hash, presence: true
  # Puzzle data consists of - fen, initial_move, lines
  validates :puzzle_data, presence: true
  before_create :recalculate_and_set_puzzle_data_hash
  before_save :recalculate_and_set_puzzle_data_hash

  # Any string that can be used to uniquely identify a puzzle
  def self.find_by_id(puzzle_id)
    Puzzle.find_by(puzzle_id: puzzle_id)
  end

  # Generate a unique for the puzzle based on the input puzzle data
  def self.data_hash(puzzle_data)
    Digest::MD5.hexdigest(puzzle_data.to_json)[0..8]
  end

  # Create a puzzle from some parsed JSON data
  def self.create_or_find_from_puzzle_data(data)
    puzzle = Puzzle.find_by(
      puzzle_data_hash: Puzzle.data_hash(data[:puzzle_data])
    )
    return puzzle if puzzle.present?
    Puzzle.create!({
      puzzle_data: data[:puzzle_data],
      metadata: data[:metadata]
    })
  end

  # Populate puzzles database from Lichess puzzles and try to map them
  # 1-to-1 with lichess puzzle ids
  def self.populate_from_lichess_puzzle_json_file(
    json_puzzle_files = Dir.glob(Rails.root.join("data/lichess/[0-9]*.json"))
  )
    if Puzzle.count > 0
      "Can only import lichess puzzle files from an empty database"
      return
    end
    # Expecting to load a json file with this lichess puzzle id next
    upcoming_lichess_puzzle_id = 1
    # Loads JSON files in order - 1.json 2.json 3.json 5.json 10.json ...
    sorted_json_puzzle_filenames = json_puzzle_files.sort_by do |filename|
      filename[/([0-9]+)\.json/, 1].to_i
    end
    sorted_json_puzzle_filenames.each do |json_puzzle_file|
      puzzle_json_data = JSON.parse(open(json_puzzle_file).read)
      puts puzzle_json_data
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
          Puzzle.create_and_destroy_blank
          upcoming_lichess_puzzle_id += 1
        end
      end
      puts "Lichess puzzle: #{lichess_puzzle_id}"
      # By now, the upcoming JSON data is from the expected lichess
      # puzzle id.
      created_puzzle = Puzzle.create!({
        puzzle_id: lichess_puzzle_id,
        puzzle_data: puzzle_json_data["puzzle_data"],
        metadata: puzzle_json_data["metadata"].merge({
          "source": "lichess"
        }),
        puzzle_data_hash: Puzzle.data_hash(puzzle_json_data)
      })
      upcoming_lichess_puzzle_id = lichess_puzzle_id + 1
      if Puzzle.order('id DESC').first.id != lichess_puzzle_id
        puts "Error matching puzzle ids with lichess puzzle ids"
        return
      end
    end
    if sorted_json_puzzle_filenames == Puzzle.count
      puts "Successfully imported #{Puzzle.count} Lichess puzzles!"
    end
  end

  # Goes through all existing puzzles and creates a Puzzle
  # out of any puzzles that haven't been seen before
  def self.populate_from_existing_puzzles
  end

  # Tries to parse a file glob as a set of source puzzle data files
  # Currently unused
  def self.populate_from_json_files(glob)
    Dir.glob(glob).each do |filename|
      json_file_data = JSON.parse(filename)
      json_file_data.each do |json_file_row_data|
        # Lichess Puzzle data format
        json_file_row_data["fen"]
        json_file_row_data["lines"]
        json_file_row_data["initialMove"]
        json_file_row_data["id"]
        Puzzle.create_or_find_from_puzzle_data({
          # The positions in a puzzle uniquely identify it
          puzzle_data: {
            fen: json_file_row_data["fen"],
            initial_move: json_file_row_data["initialMove"],
            lines: json_file_row_data["lines"]
          },
          metadata: {
            source: "lichess",
            lichess_puzzle_id: json_file_row_data["id"]
          }
        })
      end
    end
  end

  private

  # Hack for matching puzzle ids with lichess puzzle ids
  def self.create_and_destroy_blank
    p = Puzzle.create!({
      puzzle_id: "blank",
      puzzle_data_hash: 'blank',
      puzzle_data: { b: 0 }
    })
    p.destroy!
  end

  def recalculate_and_set_puzzle_data_hash
    self.puzzle_data_hash = Puzzle.data_hash(self.puzzle_data)
  end
end