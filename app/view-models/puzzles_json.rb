# Format an array of puzzles into a json response

class PuzzlesJson

  def initialize(puzzles)
    @puzzles = puzzles
  end

  def to_json
    {
      puzzles: @puzzles.map(&:simplified_data)
    }
  end
end
