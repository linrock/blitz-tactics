class Level < ActiveRecord::Base
  has_many :level_attempts

  validates_presence_of :slug
  validates_presence_of :secret_key
  validate :require_unique_puzzle_ids
  validate :require_puzzles_to_exist

  before_validation :set_secret_key
  before_validation :set_default_options


  def name
    super || slug.gsub('-', ' ').capitalize
  end

  def next_level
    Level.find(id + 1)
  end

  def puzzles
    # TODO better way of ensuring order
    pz = []
    puzzle_ids.each do |id|
      pz << LichessPuzzle.find(id)
    end
    pz
  end

  # TODO better import/export system
  def export_puzzle_ids
    puzzles.map(&:id)
  end

  def set_puzzle_ids!(ids)
    self.puzzle_ids = ids
    self.save!
  end

  private

  def set_secret_key
    self.secret_key ||= SecureRandom.hex(8)
  end

  def set_default_options
    self.options ||= {}
  end

  def require_unique_puzzle_ids
    if puzzle_ids.uniq.length != puzzle_ids.length
      errors.add :puzzle_ids, "must all be unique!"
    end
  end

  def require_puzzles_to_exist
    if LichessPuzzle.find(puzzle_ids).length != puzzle_ids.length
      errors.add :puzzle_ids, "must all exist!"
    end
  end

end
