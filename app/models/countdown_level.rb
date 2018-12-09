class CountdownLevel < ActiveRecord::Base
  has_many :countdown_puzzles, dependent: :destroy

  def self.today
    Date.today
  end

  def self.todays_date
    today.strftime "%b %-d, %Y"
  end

  def self.todays_level
    find_by(name: today.to_s)
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
    countdown_puzzles.order('id ASC')
  end

  def first_puzzle
    puzzles.first
  end
end
