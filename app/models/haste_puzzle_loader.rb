module HastePuzzleLoader

  def self.create_haste_puzzles_from_json_file
    puts "#{HastePuzzle.count} haste puzzles in db. Creating haste puzzles..."
    num_checked = 0
    num_created = 0
    open(Rails.root.join(PuzzleLoader::HASTE_PUZZLE_SOURCE), "r") do |f|
      haste_puzzle_list = JSON.parse(f.read)
      ActiveRecord::Base.transaction do
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
        puts "Created #{num_created} haste puzzles out of #{num_checked} puzzles in .json file"
      end
    end
  end

  def self.destroy_haste_puzzles_from_old_lichess_batch
    ActiveRecord::Base.transaction do
      HastePuzzle.where("(data ->> 'id')::int <= 60120").destroy_all
    end
  end
end
