class HomepageController < ApplicationController
  before_action :set_user, only: [:home]
  before_action :set_homepage_puzzles, only: [:home]

  def home
    @background_img = "bg.svg"
    @background_overlay = "rgba(0, 0, 0, 0.1)"
    @world_number = 1
    @world_name = "Just getting started"
    
    # Adventure mode enabled flag - controlled by feature flag
    @adventure_mode_enabled = FeatureFlag.enabled?(:adventure_mode)
    
    # Find the latest incomplete level for the user
    @latest_incomplete_level = find_latest_incomplete_level(current_user) if @adventure_mode_enabled && current_user
    
    # Only load adventure data if adventure mode is enabled
    if @adventure_mode_enabled
      # Load adventure levels
      @adventure_levels = load_adventure_levels
      
      if @adventure_levels.any?
        # Determine which level to show (from URL parameter or user's latest unlocked level)
        requested_level = (params[:level] || params[:level_number]).to_i
        if requested_level > 0
          # Check if user can access this level
          if current_user && !can_user_access_level?(requested_level, current_user)
            # User cannot access this level, redirect to their latest unlocked level
            redirect_to "/?level=#{@latest_incomplete_level || 1}" and return
          end
          
          # Try to load the requested level
          @current_adventure_level = load_adventure_level(requested_level)
          @current_adventure_level_number = requested_level
        else
          # Show the user's latest unlocked level by default
          if current_user && @latest_incomplete_level
            @current_adventure_level = load_adventure_level(@latest_incomplete_level)
            @current_adventure_level_number = @latest_incomplete_level
          else
            # Fallback to first level if no user or no incomplete levels
            @current_adventure_level = @adventure_levels.first
            @current_adventure_level_number = @current_adventure_level['level']
          end
        end
        
        if @current_adventure_level
          # Check if the current level is completed
          @current_level_completed = current_user ? adventure_level_completed_by_user?(@current_adventure_level_number, current_user) : false
          
          # Load the first puzzle for the current level
          @current_adventure_puzzle = load_adventure_puzzle(@current_adventure_level_number)
        end
      end
    end
    
    render "/home"
  end

  private

  def set_user
    @user = current_user || NilUser.new
  end

  def set_homepage_puzzles
    @hours_until_tomorrow = 24 - DateTime.now.hour
    @speedrun_level = SpeedrunLevel.todays_level
    @speedrun_puzzle = @speedrun_level.first_puzzle
    @speedrun_theme = @speedrun_level.theme
    @countdown_level = CountdownLevel.todays_level
    @countdown_puzzle = @countdown_level.first_puzzle
    @haste_puzzle = HastePuzzle.random
    @mate_in_one_puzzle = MateInOnePuzzle.random
    @rook_endgames_puzzle = RookEndgamePuzzle.random
    @openings_puzzle = OpeningPuzzle.random
    @rated_puzzle = RatedPuzzle.order('rating ASC').take(10).shuffle.first
    @scoreboard = Scoreboard.new

    # user-specific
    @infinity_puzzle = @user.next_infinity_puzzle
    @haste_best_score = @user.best_haste_score(Time.zone.today)
    @mate_in_one_best_score = @user.best_mate_in_one_score(Time.zone.today)
    @rook_endgames_best_score = @user.best_rook_endgames_score(Time.zone.today)
    @openings_best_score = @user.best_openings_score(Time.zone.today)
    @three_best_score = @user.best_three_score(Time.zone.today)
    @best_speedrun_time = @user.best_speedrun_time(@speedrun_level)
    @repetition_level = @user.highest_repetition_level_unlocked
    @countdown_level_score = @user.best_countdown_score(@countdown_level)
    @user_rating = @user.user_rating&.rating_string || "Unrated"
  end

  def find_latest_incomplete_level(user)
    return nil unless user
    
    # Find the highest level number that the user has unlocked but not completed
    user_unlocked_levels = user.unlocked_adventure_levels.pluck(:level_number)
    return nil if user_unlocked_levels.empty?
    
    # Find the highest level that's not completed
    user_unlocked_levels.max do |level_num|
      if adventure_level_completed_by_user?(level_num, user)
        -1 # Completed levels get negative priority
      else
        level_num # Incomplete levels get their level number as priority
      end
    end
  end

  def load_adventure_levels
    worlds_file = Rails.root.join("data/game-modes/worlds.yml")
    return [] unless File.exist?(worlds_file)
    
    YAML.load_file(worlds_file)["worlds"]
  rescue => e
    Rails.logger.error "Failed to load adventure levels: #{e.message}"
    []
  end

  def load_adventure_level(level_number)
    @adventure_levels.find { |level| level['level'] == level_number }
  end

  def load_adventure_puzzle(level_number)
    level = load_adventure_level(level_number)
    return nil unless level && level['puzzles'] && level['puzzles'].any?
    
    puzzle_id = level['puzzles'].first
    LichessV2Puzzle.find_by(puzzle_id: puzzle_id) || Puzzle.find_by(id: puzzle_id)
  end

  def can_user_access_level?(level_number, user)
    return false unless user
    
    # User can access level 1 by default
    return true if level_number == 1
    
    # Check if user has unlocked this level
    user.unlocked_adventure_levels.exists?(level_number: level_number)
  end

  def adventure_level_completed_by_user?(level_number, user)
    return false unless user
    
    user.completed_adventure_levels.exists?(level_number: level_number)
  end
end
