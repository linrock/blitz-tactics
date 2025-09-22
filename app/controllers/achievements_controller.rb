class AchievementsController < ApplicationController
  before_action :authenticate_user!

  def index
    # This will be used to track user progress in the future
    # For now, we'll just display the static achievements list
  end
end
