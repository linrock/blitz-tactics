class SpeedrunLevel < ActiveRecord::Base
  LEVELS_DIR = Rails.root.join("data/game-modes/speedruns")

  has_many :speedrun_puzzles, dependent: :destroy
  has_many :completed_speedruns, dependent: :destroy

  validates :name, presence: true, uniqueness: true

  def self.today
    Time.zone.today
  end

  def self.todays_date
    today.strftime "%b %-d, %Y"
  end

  def self.todays_level
    find_or_create_by(name: today.to_s)
  end

  def self.yesterday
    Date.yesterday
  end

  def self.yesterdays_level
    find_by(name: yesterday.to_s)
  end

  def self.two_days_ago_level
    find_by(name: 2.days.ago.to_date.to_s)
  end

  # Returns the raw JSON data (either array or themed object)
  def raw_data
    json_data_filename = LEVELS_DIR.join("speedrun-#{name}.json")
    unless File.exist? json_data_filename
      # TODO fix race condition where concurrent requests will trigger this
      # Use themed creator as primary method
      ThemedSpeedrunLevelCreator.export_puzzles_for_date(Date.strptime(name))
    end
    open(json_data_filename, 'r') { |f| JSON.parse(f.read) }
  end

  # Returns just the puzzles array (for backward compatibility)
  def puzzles
    data = raw_data
    # Check if it's the new themed format or old array format
    if data.is_a?(Hash) && data.key?("puzzles")
      data["puzzles"]
    else
      # Old format - just an array of puzzles
      data
    end
  end

  # Returns the theme for themed speedruns (nil for old format)
  def theme
    data = raw_data
    if data.is_a?(Hash) && data.key?("theme")
      data["theme"]
    else
      nil
    end
  end

  # Check if this is a themed speedrun
  def themed?
    !theme.nil?
  end

  def first_puzzle
    puzzle_list = puzzles
    return nil if puzzle_list.empty?
    
    puzzle_id = puzzle_list.first["id"]
    
    # Try to find by puzzle_id first (for LichessV2Puzzle)
    puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
    return puzzle if puzzle
    
    # Fallback to finding by database ID (for legacy Puzzle model)
    Puzzle.find_by(id: puzzle_id)
  end

  def num_puzzles
    @num_puzzles ||= speedrun_puzzles.count
  end
end
