class AchievementsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_achievements_feature_flag

  def index
    # This will be used to track user progress in the future
    # For now, we'll just display the static achievements list
  end

  private

  def check_achievements_feature_flag
    unless FeatureFlag.enabled?(:achievements)
      raise ActionController::RoutingError, 'Not Found'
    end
  end
end
