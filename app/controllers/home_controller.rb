class HomeController < ApplicationController
  before_filter :redirect_to_highest_level

  def index
  end

  private

  def redirect_to_highest_level
    return unless current_user
    level = Level.find(current_user.highest_level_unlocked)
    redirect_to "/#{level.slug}"
  end

end
