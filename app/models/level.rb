class Level < ActiveRecord::Base
  has_many :level_attempts

  validates_presence_of :slug
  validates_presence_of :secret_key

  before_validation :set_secret_key


  def name
    slug.gsub('-', ' ').capitalize
  end

  def next_level
    Level.find(id + 1)
  end

  def puzzles
    LichessPuzzle.find(puzzle_ids)
  end

  private

  def set_secret_key
    self.secret_key ||= SecureRandom.hex(8)
  end

end
