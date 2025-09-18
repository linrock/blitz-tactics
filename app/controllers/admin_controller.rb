class AdminController < ApplicationController
  before_action :require_admin_access!

  def index
    @time_period = params[:period] || 'week'
    @stats = game_mode_stats(@time_period)
    @solved_puzzle_stats = solved_puzzle_stats(@time_period)
  end

  private

  def require_admin_access!
    unless user_signed_in? && current_user.id == 1
      render "pages/not_found", status: 404
    end
  end

  def game_mode_stats(period = 'week')
    end_date = Date.current
    
    # Determine the date range based on period
    if period == 'month'
      start_date = end_date - 29.days  # Past 30 days
      @period_label = "Past 30 Days"
      @period_days = 30
    else
      start_date = end_date - 6.days   # Past 7 days
      @period_label = "Past 7 Days"
      @period_days = 7
    end
    
    stats = {}
    
    # For each day in the selected period
    (start_date..end_date).each do |date|
      day_stats = {}
      
      # Count completions for each game mode on this day
      day_stats[:infinity] = SolvedInfinityPuzzle.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:speedrun] = CompletedSpeedrun.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:countdown] = CompletedCountdownLevel.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:haste] = CompletedHasteRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:mate_in_one] = CompletedMateInOneRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:rook_endgames] = CompletedRookEndgamesRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:openings] = CompletedOpeningsRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:three] = CompletedThreeRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:repetition_rounds] = CompletedRepetitionRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:repetition_levels] = CompletedRepetitionLevel.where(created_at: date.beginning_of_day..date.end_of_day).count
      
      # Calculate total for the day
      day_stats[:total] = day_stats.values.sum
      
      stats[date] = day_stats
    end
    
    stats
  end

  def solved_puzzle_stats(period = 'week')
    end_date = Date.current
    
    # Determine the date range based on period
    if period == 'month'
      start_date = end_date - 29.days  # Past 30 days
    else
      start_date = end_date - 6.days   # Past 7 days
    end
    
    stats = {}
    
    # For each day in the selected period
    (start_date..end_date).each do |date|
      # Count unique puzzles solved on this day (using created_at for first-time solves)
      day_puzzle_count = SolvedPuzzle.where(created_at: date.beginning_of_day..date.end_of_day).count
      
      # Count unique users who solved puzzles on this day
      day_user_count = SolvedPuzzle.where(created_at: date.beginning_of_day..date.end_of_day)
                                   .distinct
                                   .count(:user_id)
      
      stats[date] = {
        puzzles: day_puzzle_count,
        users: day_user_count
      }
    end
    
    stats
  end
end
