# a haste mode puzzle. No levels exist in haste mode. Only random puzzles

class HastePuzzle < ActiveRecord::Base
  include PuzzleRecord

  COLORS = %w( w b )

  validates :puzzle_hash, uniqueness: true
  validates :difficulty, numericality: true
  validates :color, inclusion: COLORS

  def self.random
    unscoped.where(difficulty: 0).order(Arel.sql('RANDOM()')).first
  end

  # random set of puzzles with increasing difficulty
  def self.random_level(n)
    colors = COLORS.shuffle.cycle
    (0..10).flat_map do |difficulty|
      unscoped.where(color: colors.next, difficulty: difficulty)
        .order(Arel.sql('RANDOM()')).limit(n/10).to_a
    end
  end
end
