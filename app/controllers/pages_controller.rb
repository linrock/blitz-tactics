class PagesController < ApplicationController
  before_action :set_user, only: [:home]

  def home
    @hours_until_tomorrow = 24 - DateTime.now.hour
    @speedrun_level = SpeedrunLevel.todays_level
    @speedrun_puzzle = @speedrun_level.first_puzzle
    @countdown_level = CountdownLevel.todays_level
    @countdown_puzzle = @countdown_level.first_puzzle
    @haste_puzzle = HastePuzzle.random
    @rated_puzzle = RatedPuzzle.order('rating ASC').take(10).shuffle.first
    @scoreboard = Scoreboard.new

    # user-specific
    @infinity_puzzle = @user.next_infinity_puzzle
    @haste_best_score = @user.best_haste_score(Date.today)
    @three_best_score = @user.best_three_score(Date.today)
    @best_speedrun_time = @user.best_speedrun_time(@speedrun_level)
    @repetition_level = @user.highest_repetition_level_unlocked
    @countdown_level_score = @user.best_countdown_score(@countdown_level)
    @user_rating = @user.user_rating&.rating_string || "Unrated"

    render "/home"
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
    @scoreboard = Scoreboard.new
    @recent_days = {
      "2 days ago" => :two_days_ago_level,
      "Yesterday"  => :yesterdays_level,
      "Today"      => :todays_level
    }
  end

  def pawn_endgames
  end

  def about
  end
end
