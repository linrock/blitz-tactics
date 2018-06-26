# level-1, level-2, etc.

class RepetitionLevel < ActiveRecord::Base
  has_many :repetition_puzzles, dependent: :destroy
  has_many :completed_repetition_levels, dependent: :destroy
  has_many :completed_repetition_rounds, dependent: :destroy

  validates :number, presence: true, numericality: { greater_than: 0 }

  def self.number(number)
    find_by(number: number)
  end

  def first_level?
    number == 1
  end

  def last_level?
    next_level.nil?
  end

  def next_level
    RepetitionLevel.find_by(number: number + 1)
  end

  def first_puzzle
    repetition_puzzles.order('id ASC').first
  end

  def path
    "/level-#{number}"
  end

  def display_name
    if name
      "Level #{number} — #{name}"
    else
      "Level #{number}"
    end
  end
end
