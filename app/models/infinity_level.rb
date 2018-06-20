# puzzle_id_array = ordered list of puzzle ids
# puzzle_id_map = map of new lichess puzzle ids (puzzle.id) => { p: prev_id, n: next_id }

class InfinityLevel < ActiveRecord::Base
  before_validation :generate_puzzle_id_map!, if: :puzzle_id_array_changed?

  validates :difficulty,
    presence: true,
    uniqueness: true,
    inclusion: %w( easy medium hard insane )
  validate :puzzle_ids_are_unique
  validate :check_structure_of_puzzle_id_map

  def n_puzzles
    puzzle_id_array.length
  end

  def next_n_puzzles_from(puzzle_id, n)
    inf_puzzle = puzzle_id ? puzzle_at(puzzle_id) : first_puzzle
    n.times.map do
      if inf_puzzle.nil?
        nil
      else
        puzzle = inf_puzzle.puzzle
        inf_puzzle = inf_puzzle.next_puzzle
        puzzle
      end
    end.compact
  end

  # returns infinity puzzle
  def puzzle_at(puzzle_id)
    InfinityPuzzle.new(difficulty, puzzle_id)
  end

  # returns infinity puzzle
  def first_puzzle
    puzzle_at(first_puzzle_id)
  end

  # puzzle_id helpers
  def first_puzzle_id
    puzzle_id_array.first
  end

  def last_puzzle_id
    puzzle_id_array.last
  end

  def prev_puzzle_id(puzzle_id)
    puzzle_id_map[puzzle_id.to_s]["p"]
  end

  def next_puzzle_id(puzzle_id)
    puzzle_id_map[puzzle_id.to_s]["n"]
  end

  def includes_puzzle_id?(puzzle_id)
    puzzle_id_map[puzzle_id.to_s].present?
  end

  def add_puzzle_id(puzzle_id)
    return if includes_puzzle_id?(puzzle_id)
    self.puzzle_id_array << puzzle_id
    self.save!
  end

  private

  def puzzle_ids_are_unique
    Set.new(puzzle_id_array).count == puzzle_id_array.length
  end

  def check_structure_of_puzzle_id_map
    return if puzzle_id_array.length == 0
    first = puzzle_id_map[first_puzzle_id.to_s]
    last = puzzle_id_map[last_puzzle_id.to_s]
    unless first["p"].nil?
      errors.add :puzzle_id_map, "has invalid start node"
    end
    unless last["n"].nil?
      errors.add :puzzle_id_map, "has invalid end node"
    end
    node = first
    traversed_puzzle_ids = [first_puzzle_id]
    while node.present?
      next_node = node["n"]
      traversed_puzzle_ids << next_node if next_node.present?
      node = puzzle_id_map[node["n"].to_s]
    end
    unless traversed_puzzle_ids == puzzle_id_array
      errors.add :puzzle_id_map, "didn't match puzzle_id_array when traversed"
    end
  end

  # p = previous puzzle.id
  # n = next puzzle.id
  def generate_puzzle_id_map!
    map = {}
    current_puzzle_id = nil
    puzzle_id_array.each do |puzzle_id|
      map[puzzle_id] = {}
      if current_puzzle_id 
        map[current_puzzle_id][:n] = puzzle_id
        map[puzzle_id][:p] = current_puzzle_id
      end
      current_puzzle_id = puzzle_id
    end
    self.puzzle_id_map = map
  end
end
