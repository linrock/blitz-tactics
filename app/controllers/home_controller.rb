class HomeController < ApplicationController
  def index
    @level = current_user&.highest_level_unlocked || Level.first
  end
end
