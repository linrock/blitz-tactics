class PagesController < ApplicationController
  def home
    if current_user
      @infinity_puzzle = current_user.next_infinity_puzzle
      @best_speedrun_time = current_user.best_speedrun_time
    else
      @infinity_puzzle = InfinityLevel.easy.first_puzzle.puzzle
      @best_speedrun_time = 'None'
    end
    @speedrun_puzzle = SpeedrunLevel.first_puzzle
    @level = current_user&.highest_level_unlocked || Level.first
  end

  def positions
  end

  def position
    if params[:id].present?
      @position = Position.find(params[:id])
    else
      @position = Position.new(fen: params[:fen], goal: params[:goal])
    end
  end

  def defined_position
    pathname = request.path.gsub(/\/\z/, '')
    @route = StaticRoutes.new.route_map[pathname]
  end

  def scoreboard
    @ranked_users = UserScoreboard.ranked_users(30)
  end

  def pawn_endgames
  end

  def about
  end
end
