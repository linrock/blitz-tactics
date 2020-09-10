# Loads puzzles from .json files in the /data dir

COUNTDOWN_PUZZLE_SOURCE = "data/countdowns/countdown-*.json"
SPEEDRUN_PUZZLE_SOURCE = "data/speedruns/speedrun-*.json"
HASTE_PUZZLE_SOURCE = "data/haste/puzzles.json"
RATED_PUZZLE_SOURCE = "data/rated/puzzles.json"
REPETITION_PUZZLE_SOURCE = "data/repetition/level-*.json"

# Loads .json puzzle data files into the database
class PuzzleLoader

  def self.create_puzzles
    create_countdown_puzzles_from_json_files
    create_speedrun_puzzles_from_json_files
    create_haste_puzzles_from_json_files
    create_rated_puzzles_from_json_files
    create_repetition_puzzles_from_json_files
  end

  private

  def self.create_countdown_puzzles_from_json_files
    num_checked = 0
    num_created = 0
    Dir.glob(Rails.root.join(COUNTDOWN_PUZZLE_SOURCE)).each do |filename|
      level_name = filename[/countdown-([\d\-]+).json/, 1]
      if CountdownLevel.find_by(name: level_name)
        # puts "Countdown level #{level_name} already exists. Ignoring #{filename}"
      else
        # puts "Loading countdown level #{level_name} from #{filename}"
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
    num_checked = 0
    num_created = 0
    Dir.glob(Rails.root.join(SPEEDRUN_PUZZLE_SOURCE)).each do |filename|
      level_name = filename[/speedrun-([\d\-]+).json/, 1]
      if SpeedrunLevel.find_by(name: level_name)
        # puts "Speedrun level #{level_name} already exists. Ignoring #{filename}"
      else
        # puts "Creating speedrun level #{level_name} from #{filename}"
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

  def self.create_haste_puzzles_from_json_files
    # TODO
    open(Rails.root.join(HASTE_PUZZLE_SOURCE)) do |f|
      haste_puzzle_list = JSON.parse(f.read)
      puts "Found #{haste_puzzle_list.length} haste puzzles in .json file"
    end
  end

  def self.create_rated_puzzles_from_json_files
    # TODO
    open(Rails.root.join(RATED_PUZZLE_SOURCE)) do |f|
      rated_puzzle_list = JSON.parse(f.read)
      puts "Found #{rated_puzzle_list.length} rated puzzles in .json file"
    end
  end

  def self.create_repetition_puzzles_from_json_files
    # TODO
    num_checked = 0
    num_created = 0
    Dir.glob(Rails.root.join(REPETITION_PUZZLE_SOURCE)).each do |filename|
      level_name = filename[/level-([\d]+).json/, 1]
      RepetitionLevel.find_by(name: level_name)
      num_checked += 1
    end
    puts "Created #{num_created} repetition levels out of #{num_checked} .json files"
  end
end
