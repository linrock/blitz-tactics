# levels in repetition mode

class Level < ActiveRecord::Base
  has_many :level_attempts

  before_validation :set_secret_key
  before_validation :set_default_options

  validates_presence_of :slug
  validates_presence_of :secret_key
  validate :require_unique_puzzle_ids
  validate :require_puzzles_to_exist

  delegate :path, :display_name, to: :level_display

  def self.by_number(number)
    find_by(slug: "level-#{number}")
  end

  def first_level?
    slug == "level-1"
  end

  def number
    slug[/(\d+)/, 1].to_i
  end

  def next_level
    Level.find_by_id(id + 1)
  end

  def puzzles
    LichessPuzzle.find(puzzle_ids).index_by(&:id).values_at(*puzzle_ids)
  end

  def first_puzzle
    puzzles.first
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

  def level_display
    LevelDisplay.new(self)
  end

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
