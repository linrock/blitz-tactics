class LevelGenerator

  LEVEL_SIZE = 20
  N_LEVELS   = 50

  def puzzle_source
    LichessPuzzle.rating_lt(1600).vote_gt(35).white_to_move
  end

  def deduplicated_source
    existing = existing_puzzle_ids
    puzzle_source.shuffle(:random => random_seed).select do |puzzle|
      !existing.include?(puzzle.id)
    end
  end

  def existing_puzzle_ids
    Set.new(Level.all.map(&:puzzle_ids).flatten.uniq)
  end

  def build_levels!
    puzzles = deduplicated_source.take(LEVEL_SIZE * N_LEVELS)
    puzzles.each_slice(LEVEL_SIZE).each_with_index do |level_puzzles, id|
      puzzle_ids = level_puzzles.sort_by(&:rating).map(&:id)
      slug = level_slug(id + 1)
      Level.create!({ :slug => slug, :puzzle_ids => puzzle_ids })
      puts "Created #{slug}"
    end
    levels = Level.all
    levels.each_with_index do |level, i|
      level.update_attribute :next_level_id, levels[i + 1]&.id
    end
  end

  def rebuild_levels!
    Level.destroy_all
    build_levels!
  end

  def level_slug(id)
    "level-#{id}"
  end

  def add_new_level(puzzle_ids)
    last_level = Level.last
    new_level = Level.create!({ :slug => level_slug(last_level.id + 1),
                                :puzzle_ids => puzzle_ids })
    last_level.update_attribute :next_level_id, new_level.id
  end

  private

  def random_seed
    Random.new(1)
  end
end
