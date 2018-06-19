class HomeController < ApplicationController
  def index
    @infinity_puzzle = NewLichessPuzzle.first
    @level = current_user&.highest_level_unlocked || Level.first
  end
end
