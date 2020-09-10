# Loads puzzles from .json files in the /data dir

COUNTDOWN_PUZZLE_SOURCE = "data/countdowns/countdown-*.json"
SPEEDRUN_PUZZLE_SOURCE = "data/speedruns/speedrun-*.json"

# Loads puzzle .json data files into the database
class PuzzleLoader

  def self.create_puzzles
    self.create_countdown_puzzles_from_json_files
    self.create_speedrun_puzzles_from_json_files
  end

  def self.create_countdown_puzzles_from_json_files
    Dir.glob(Rails.root.join(COUNTDOWN_PUZZLE_SOURCE)).each do |filename|
      level_name = filename[/countdown-([\d\-]+).json/, 1]
      if CountdownLevel.find_by(name: level_name)
        puts "Countdown level #{level_name} already exists. Ignoring #{filename}"
      else
        puts "Loading countdown level #{level_name} from #{filename}"
        level = CountdownLevel.create!(name: level_name)
        open(filename, "r") do |f|
          countdown_puzzle_list = JSON.parse(f.read)
          countdown_puzzle_list.each do |puzzle_data|
            level.countdown_puzzles.create!(data: puzzle_data)
          end
        end
      end
    end
  end

  def self.create_speedrun_puzzles_from_json_files
    Dir.glob(Rails.root.join(SPEEDRUN_PUZZLE_SOURCE)).each do |filename|
      level_name = filename[/speedrun-([\d\-]+).json/, 1]
      if SpeedrunLevel.find_by(name: level_name)
        puts "Speedrun level #{level_name} already exists. Ignoring #{filename}"
      else
        puts "Creating speedrun level #{level_name} from #{filename}"
        level = SpeedrunLevel.create!(name: level_name)
        open(filename, "r") do |f|
          speedrun_puzzle_list = JSON.parse(f.read)
          speedrun_puzzle_list.each do |puzzle_data|
            level.speedrun_puzzles.create!(data: puzzle_data)
          end
        end
      end
    end
  end
end

# PuzzleLoader.create_countdown_puzzles_from_json_files
