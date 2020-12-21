class CountdownLevel < ActiveRecord::Base
  LEVELS_DIR = Rails.root.join("data/countdowns")

  has_many :countdown_puzzles, dependent: :destroy

  def self.today
    Date.today
  end

  def self.todays_date
    today.strftime "%b %-d, %Y"
  end

  # format of name (today.to_s): "2020-09-10"
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

  def puzzles
    # countdown_puzzles.order('id ASC')
    open(LEVELS_DIR.join("countdown-#{name}.json"), 'r') do |f|
      JSON.parse(f.read)
    end
  end

  def first_puzzle
    Puzzle.find(puzzles.first["id"])
  end
end
