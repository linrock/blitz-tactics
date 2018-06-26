class PagesController < ApplicationController
  before_action :set_user, only: [:home]

  def home
    @infinity_puzzle = @user.next_infinity_puzzle
    @speedrun_puzzle = SpeedrunLevel.first_puzzle
    @best_speedrun_time = @user.best_speedrun_time
    @repetition_level = @user.highest_repetition_level_unlocked
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
    @ranked_users = User.old_scoreboard_ranks(30)
  end

  def pawn_endgames
  end

  def about
  end
end
