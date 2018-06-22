class ScoreboardController < ApplicationController

  def index
    @ranked_users = UserScoreboard.ranked_users(30)
  end
end
