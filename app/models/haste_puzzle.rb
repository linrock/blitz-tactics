# a haste mode puzzle. No levels exist in haste mode. Only random puzzles

class HastePuzzle < ActiveRecord::Base
  include PuzzleRecord

  COLORS = %w( w b )

  validates :puzzle_hash, uniqueness: true
  validates :difficulty, numericality: true
  validates :color, inclusion: COLORS

  # get a random easy puzzle to show on the homepage
  def self.random
    unscoped.where(difficulty: 0).order(Arel.sql('RANDOM()')).first
  end

  # random set of puzzles with increasing difficulty
  def self.random_level(n)
    colors = COLORS.shuffle.cycle
    puzzles = (0..8).flat_map do |difficulty|
      unscoped.where(color: colors.next, difficulty: difficulty)
        .order(Arel.sql('RANDOM()')).limit(7).to_a
    end
    puzzles + unscoped.where(color: colors.next, difficulty: 9)
      .order(Arel.sql('RANDOM()')).limit(n - 63).to_a
  end
end
