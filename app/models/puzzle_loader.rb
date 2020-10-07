# Loads puzzles from .json data files in the ./data dir into the DB
#
class PuzzleLoader
  COUNTDOWN_PUZZLE_SOURCE = "data/countdowns/countdown-*.json"
  SPEEDRUN_PUZZLE_SOURCE = "data/speedruns/speedrun-*.json"
  REPETITION_PUZZLE_SOURCE = "data/repetition/level-*.json"
  INFINITY_PUZZLE_SOURCE = "data/infinity/difficulty-*.json"

  HASTE_PUZZLE_SOURCE = "data/haste/puzzles.json"
  RATED_PUZZLE_SOURCE = "data/rated/puzzles.json"

  def self.create_puzzles
    # game modes where puzzles are spread across many files
    create_countdown_puzzles_from_json_files
    create_speedrun_puzzles_from_json_files
    create_repetition_puzzles_from_json_files
    create_infinity_puzzles_from_json_files

    # game modes where puzzles are stored in a single file
    create_haste_puzzles_from_json_file
    create_rated_puzzles_from_json_file
  end

  private

  def self.create_countdown_puzzles_from_json_files
    puts "#{CountdownLevel.count} countdown levels in db. Creating countdown levels..."
    num_checked = 0
    num_created = 0
    Dir.glob(Rails.root.join(COUNTDOWN_PUZZLE_SOURCE)).sort.each do |filename|
      level_name = filename[/countdown-([\d\-]+).json/, 1]
      if CountdownLevel.find_by(name: level_name)
        # puts "Countdown level #{level_name} already exists. Ignoring #{filename}"
      else
        puts "Creating countdown level #{level_name} from #{filename}"
        level = CountdownLevel.create!(name: level_name)
        open(filename, "r") do |f|
          countdown_puzzle_list = JSON.parse(f.read)
          countdown_puzzle_list.each do |puzzle_data|
            level.countdown_puzzles.create!(data: puzzle_data)
          end
        end
        num_created += 1
      end
      num_checked += 1
    end
    puts "Created #{num_created} countdown levels out of #{num_checked} .json files"
  end

  def self.create_speedrun_puzzles_from_json_files
    puts "#{SpeedrunLevel.count} speedrun levels in db. Creating speedrun levels..."
    num_checked = 0
    num_created = 0
    Dir.glob(Rails.root.join(SPEEDRUN_PUZZLE_SOURCE)).sort.each do |filename|
      level_name = filename[/speedrun-([\d\-]+).json/, 1]
      if SpeedrunLevel.find_by(name: level_name)
        # puts "Speedrun level #{level_name} already exists. Ignoring #{filename}"
      else
        puts "Creating speedrun level #{level_name} from #{filename}"
        level = SpeedrunLevel.create!(name: level_name)
        open(filename, "r") do |f|
          speedrun_puzzle_list = JSON.parse(f.read)
          speedrun_puzzle_list.each do |puzzle_data|
            level.speedrun_puzzles.create!(data: puzzle_data)
          end
        end
        num_created += 1
      end
      num_checked += 1
    end
    puts "Created #{num_created} speedrun levels out of #{num_checked} .json files"
  end

  def self.create_haste_puzzles_from_json_file
    puts "#{HastePuzzle.count} haste puzzles in db. Creating haste puzzles..."
    num_checked = 0
    num_created = 0
    open(Rails.root.join(HASTE_PUZZLE_SOURCE)) do |f|
      haste_puzzle_list = JSON.parse(f.read)
      haste_puzzle_list.each do |puzzle|
        begin
          if HastePuzzle.create!(
            data: puzzle,
            color: puzzle["color"],
            difficulty: puzzle["difficulty"],
          )
            num_created += 1
          end
        rescue
          # Puzzle is already created. Do nothing
        end
        num_checked += 1
      end
      puts "Created #{num_created} haste puzzles out of #{num_checked} .json files"
    end
  end

  def self.create_rated_puzzles_from_json_file
    puts "#{RatedPuzzle.count} rated puzzles in db. Creating rated puzzles..."
    num_checked = 0
    num_created = 0
    open(Rails.root.join(RATED_PUZZLE_SOURCE)) do |f|
      rated_puzzle_list = JSON.parse(f.read)
      rated_puzzle_list.each do |puzzle|
        begin
          # TODO move this puzzle initialization code
          if RatedPuzzle.create(
            data: puzzle,
            color: puzzle["color"],
            initial_rating: 1500,
            initial_rating_deviation: 350,
            initial_rating_volatility: 0.06,
            rating: 1500,
            rating_deviation: 350,
            rating_volatility: 0.06
          )
            num_created += 1
          end
        rescue
          # Puzzle is already created. Do nothing
        end
        num_checked += 1
      end
      puts "Created #{num_created} rated puzzles out of #{num_checked} puzzles in .json file"
    end
  end

  def self.create_repetition_puzzles_from_json_files
    puts "#{RepetitionLevel.count} repetition levels in db. Creating repetition levels..."
    num_checked = 0
    num_created = 0
    Dir.glob(Rails.root.join(REPETITION_PUZZLE_SOURCE)).sort.each do |filename|
      level_number = filename[/level-([\d]+).json/, 1].to_i
      puts "Level number: #{level_number}"
      if RepetitionLevel.exists?(number: level_number)
        level = RepetitionLevel.number(level_number)
      else
        level = RepetitionLevel.create!(number: level_number)
        num_created += 1
      end
      open(filename) do |f|
        repetition_level_puzzle_list = JSON.parse(f.read)
        repetition_level_puzzle_list.each do |puzzle|
          level.repetition_puzzles.create(data: puzzle)
        end
        num_checked += 1
      end
    end
    puts "Created #{num_created} repetition levels out of #{num_checked} .json files"
  end

  def self.create_infinity_puzzles_from_json_files
    puts "Importing infinity puzzles..."
    Dir.glob(Rails.root.join(INFINITY_PUZZLE_SOURCE)).each do |filename|
      level_difficulty = filename[/difficulty-([a-z]+)\.json/, 1]
      infinity_level = InfinityLevel.send(level_difficulty)
      puzzle_count = infinity_level.infinity_puzzles.count
      puts "#{puzzle_count} #{level_difficulty} infinity puzzles in db"
      open(filename) do |f|
        puzzle_list = JSON.parse(f.read)
        puzzle_list.each do |puzzle|
          infinity_level.infinity_puzzles.create(data: puzzle)
        end
      end
    end
  end
end
