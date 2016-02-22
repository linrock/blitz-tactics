class PuzzleFetcher

  def initialize
    @id_range = (1..15000).to_a.shuffle
  end

  def puzzle_file(puzzle_id)
    "puzzles/#{puzzle_id}.json"
  end

  def build_result
    win = rand > 0.4 ? 1 : 0
    time = (1000 + rand * 10000 + rand * 1000).to_i
    %({"win": #{win}, "time": #{time}})
  end

  def pause_briefly
    sleep (1+rand*5).to_i
  end

  def run!
    @id_range.each do |id|
      output_file = puzzle_file(id)
      next if File.exists?(output_file)
      result = build_result
      puts "puzzle: #{id}, result: #{result}"
      %x(curl -sL -X POST "http://en.lichess.org/training/#{id}/attempt" -H "Content-Type: application/json" -d '#{result}' > #{output_file})
      pause_briefly
    end
  end

end


PuzzleFetcher.new.run!
