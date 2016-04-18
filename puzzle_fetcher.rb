class PuzzleFetcher

  def initialize
    @id_range = (1..15000).to_a.shuffle
  end

  def puzzle_file(puzzle_id)
    "puzzles/#{puzzle_id}.json"
  end

  def pause_briefly
    sleep (1+rand*5).to_i
  end

  def fetch_puzzle(puzzle_id, options = {})
    cmd = %(curl -sL "http://en.lichess.org/training/#{puzzle_id}/load" -H "X-Requested-With: XMLHttpRequest")
    if (output_file = options[:output_file])
      %x(#{cmd} > #{output_file})
    else
      %x(#{cmd})
    end
  end

  def run!
    @id_range.each do |id|
      output_file = puzzle_file(id)
      next if File.exists?(output_file)
      puts "puzzle: #{id}"
      fetch_puzzle(id, :output_file => output_file)
      pause_briefly
    end
  end

end


# PuzzleFetcher.new.run!
