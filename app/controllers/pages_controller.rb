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
    time = 7.days.ago
    n = 10
    @top_speedruns = CompletedSpeedrun.where('created_at > ?', time).unscoped
      .group(:user_id).count
      .sort_by {|_,v| -v }.take(n)
      .map {|user_id, count| [User.find_by(id: user_id), count] }
    @top_infinity = SolvedInfinityPuzzle.where('created_at > ?', time).unscoped
      .group(:user_id).count
      .sort_by {|_,v| -v }.take(n)
      .map {|user_id, count| [User.find_by(id: user_id), count] }
    @top_repetition = CompletedRepetitionLevel.where('created_at > ?', time).unscoped
      .group(:user_id).count
      .sort_by {|_,v| -v }.take(n)
      .map {|user_id, count| [User.find_by(id: user_id), count] }
    @hall_of_fame = User.all_repetition_levels_unlocked
  end

  def pawn_endgames
  end

  def about
  end
end
