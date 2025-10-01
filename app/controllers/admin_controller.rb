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

  def adventure
    # Load all adventure levels (1-100) - ALL UNLOCKED for admin preview
    @adventure_levels = []
    
    (1..100).each do |level_number|
      level_data = load_adventure_level(level_number)
      if level_data
        # Prepare puzzle set data exactly like homepage does
        adventure_puzzle_sets = level_data['puzzle_sets'].map.with_index do |set_data, index|
          first_puzzle = get_first_puzzle_for_adventure_set(set_data)
          set_data['first_puzzle'] = first_puzzle
          # For admin preview, show all sets as unlocked but not completed
          set_data['completed'] = false
          set_data['unlocked'] = true
          set_data['completion_data'] = nil # No fake completion data
          set_data
        end
        
        @adventure_levels << {
          level_number: level_number,
          data: level_data,
          puzzle_sets: adventure_puzzle_sets,
          completed: true  # Show all as completed for admin preview
        }
      end
    end
    
    # Sort from latest to earliest (highest level number first)
    @adventure_levels.sort_by! { |level| -level[:level_number] }
    
    # Debug logging
    Rails.logger.info "Loaded #{@adventure_levels.count} adventure levels for admin preview"
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

  def load_adventure_level(level_number)
    level_file = Rails.root.join("data", "game-modes", "adventure", "level-#{level_number.to_s.rjust(2, '0')}.json")
    
    return nil unless File.exist?(level_file)
    
    begin
      JSON.parse(File.read(level_file))
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing adventure level #{level_number}: #{e.message}"
      nil
    end
  end

  def format_time(time_ms)
    return "N/A" unless time_ms && time_ms > 0
    
    seconds = time_ms / 1000.0
    if seconds < 60
      "#{seconds.round(1)}s"
    else
      minutes = (seconds / 60).floor
      remaining_seconds = (seconds % 60).round(1)
      "#{minutes}m #{remaining_seconds}s"
    end
  end
  helper_method :format_time

  def get_first_puzzle_for_adventure_set(set_data)
    # Handle checkmate challenges - they use position_fen instead of puzzles
    if set_data['challenge'] == 'checkmate' && set_data['position_fen'].present?
      return {
        puzzle_id: "checkmate-#{set_data['set_index']}",
        fen: set_data['position_fen'],
        initial_fen: set_data['position_fen'],
        initial_move: nil, # No initial move for checkmate challenges
        rating: nil,
        themes: ['checkmate']
      }
    end

    # Handle regular puzzle-based challenges
    return nil unless set_data['puzzles'].present? && set_data['puzzles'].is_a?(Array)

    first_puzzle_id = set_data['puzzles'].first
    return nil if first_puzzle_id.blank?

    # Try to find the puzzle by puzzle_id
    puzzle = LichessV2Puzzle.find_by(puzzle_id: first_puzzle_id.to_s)
    return nil unless puzzle

    {
      puzzle_id: puzzle.puzzle_id,
      fen: puzzle.initial_fen,
      initial_fen: puzzle.initial_fen,
      initial_move: puzzle.moves_uci[0],
      rating: puzzle.rating,
      themes: puzzle.themes
    }
  end
end
