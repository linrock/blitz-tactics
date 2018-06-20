module PuzzleImporter

  def import_from_json_files
    existing_puzzle_ids = Set.new NewLichessPuzzle.pluck(:puzzle_id)
    new_puzzle_files = Dir.glob("data/new-lichess/*.json").select do |filename|
      !existing_puzzle_ids.include?(filename[/(\d+)/, 1].to_i)
    end
    puts "Found #{new_puzzle_files.length} puzzles to import"
    new_puzzle_files.each do |filename|
      puts filename
      open(filename, 'r') do |f|
        json_data = JSON.parse(f.read)
        ActiveRecord::Base.logger.silence do
          NewLichessPuzzle.find_or_create_from_raw_data(json_data)
        end
      end
    end
    puts "Imported #{new_puzzle_files.length} puzzles"
    true
  end

  extend self
end
