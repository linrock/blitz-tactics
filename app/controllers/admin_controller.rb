class AdminController < ApplicationController
  before_action :require_admin_access!

  def index
    @time_period = params[:period] || 'week'
    @stats = game_mode_stats(@time_period)
    @solved_puzzle_stats = solved_puzzle_stats(@time_period)
    @feature_flags = FeatureFlag.all.order(:name)
  end

  def feature_flags
    @feature_flags = FeatureFlag.all.order(:name)
  end

  def create_feature_flag
    @feature_flag = FeatureFlag.new(feature_flag_params)
    
    if @feature_flag.save
      redirect_to admin_feature_flags_path, notice: 'Feature flag created successfully!'
    else
      @feature_flags = FeatureFlag.all.order(:name)
      render :feature_flags, status: :unprocessable_entity
    end
  end

  def update_feature_flag
    @feature_flag = FeatureFlag.find(params[:id])
    
    if @feature_flag.update(feature_flag_params)
      redirect_to admin_feature_flags_path, notice: 'Feature flag updated successfully!'
    else
      @feature_flags = FeatureFlag.all.order(:name)
      render :feature_flags, status: :unprocessable_entity
    end
  end

  def toggle_feature_flag
    @feature_flag = FeatureFlag.find(params[:id])
    @feature_flag.toggle!
    
    redirect_to admin_feature_flags_path, notice: "Feature flag '#{@feature_flag.name}' #{@feature_flag.enabled? ? 'enabled' : 'disabled'}!"
  end

  def destroy_feature_flag
    @feature_flag = FeatureFlag.find(params[:id])
    @feature_flag.destroy
    
    redirect_to admin_feature_flags_path, notice: 'Feature flag deleted successfully!'
  end

  private

  def require_admin_access!
    unless user_signed_in? && current_user.id == 1
      render "pages/not_found", status: 404
    end
  end

  def feature_flag_params
    params.require(:feature_flag).permit(:name, :enabled, :description)
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
