class HomeController < ApplicationController
  def index
    @infinity_puzzle = InfinityLevel.find_by(difficulty: 'easy').first_puzzle.puzzle
    @level = current_user&.highest_level_unlocked || Level.first
  end
end
