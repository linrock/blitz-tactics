# level-1, level-2, etc.

class RepetitionLevel < ActiveRecord::Base
  has_many :repetition_puzzles, dependent: :destroy
  has_many :completed_repetition_levels, dependent: :destroy
  has_many :completed_repetition_rounds, dependent: :destroy

  validates :number,
    presence: true, uniqueness: true, numericality: { greater_than: 0 }

  def self.number(number)
    find_by(number: number)
  end

  # Exports all repetition levels to data files in data/repetition/*.json
  def self.export_all_levels
    all.each do |level|
      filename = "level-#{level.number}.json"
      puts "Exporting #{filename}"
      file_path = Rails.root.join("data/repetition/#{filename}")
      level_json = level.repetition_puzzles.map do |p|
        p.as_json({ lichess_puzzle_id: true })
      end.to_json
      `echo '#{level_json}' | jq . > #{file_path}`
    end
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

  # shown under the board on homepage and repetition level page
  def display_name
    if name
      "Level #{number} — #{name}"
    else
      "Level #{number}"
    end
  end

  # top five fastest users and round times for this level
  def high_scores
    completed_repetition_rounds
      .group(:user_id).minimum(:elapsed_time_ms)
      .sort_by {|user_id, time| time }.take(5)
      .map do |user_id, time|
        [
          User.find_by(id: user_id),
          Time.at(time / 1000).strftime("%M:%S").gsub(/^0/, '')
        ]
      end
  end
end
