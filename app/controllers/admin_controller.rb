class AdminController < ApplicationController
  before_action :require_admin_access!

  def index
    @stats = game_mode_stats
  end

  private

  def require_admin_access!
    unless user_signed_in? && current_user.id == 1
      render "pages/not_found", status: 404
    end
  end

  def game_mode_stats
    # Get the past 7 days
    end_date = Date.current
    start_date = end_date - 6.days
    
    stats = {}
    
    # For each day in the past 7 days
    (start_date..end_date).each do |date|
      day_stats = {}
      
      # Count completions for each game mode on this day
      day_stats[:infinity] = SolvedInfinityPuzzle.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:speedrun] = CompletedSpeedrun.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:countdown] = CompletedCountdownLevel.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:haste] = CompletedHasteRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:mate_in_one] = CompletedMateInOneRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:rook_endgames] = CompletedRookEndgamesRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:three] = CompletedThreeRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:repetition_rounds] = CompletedRepetitionRound.where(created_at: date.beginning_of_day..date.end_of_day).count
      day_stats[:repetition_levels] = CompletedRepetitionLevel.where(created_at: date.beginning_of_day..date.end_of_day).count
      
      # Calculate total for the day
      day_stats[:total] = day_stats.values.sum
      
      stats[date] = day_stats
    end
    
    stats
  end
end
