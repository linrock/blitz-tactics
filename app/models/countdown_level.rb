class CountdownLevel < ActiveRecord::Base
  has_many :countdown_puzzles, dependent: :destroy

  def self.todays_level
    first
  end

  def puzzles
    countdown_puzzles.order('id ASC')
  end
end
