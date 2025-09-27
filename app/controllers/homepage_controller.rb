class HomepageController < ApplicationController
  before_action :set_user, only: [:home, :next_level]
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
        # Determine which level to show (from URL parameter, session, or user's latest unlocked level)
        requested_level = (params[:level] || params[:level_number]).to_i
        if requested_level > 0
          # Check if user can access this level
          if current_user && !can_user_access_level?(requested_level, current_user)
            # User cannot access this level, redirect to their latest unlocked level
            redirect_to "/" and return
          end
          
          # Update session to remember this level and redirect to homepage without query param
          session[:current_adventure_level] = requested_level
          redirect_to "/" and return
        else
          # Check session first, then user's latest unlocked level
          session_level = session[:current_adventure_level].to_i
          if session_level > 0
            # Check if user can access the session level
            if current_user && can_user_access_level?(session_level, current_user)
              @current_adventure_level = load_adventure_level(session_level)
              @current_adventure_level_number = session_level
            else
              # Session level not accessible, fall back to latest unlocked level
              if current_user && @latest_incomplete_level
                @current_adventure_level = load_adventure_level(@latest_incomplete_level)
                @current_adventure_level_number = @latest_incomplete_level
                session[:current_adventure_level] = @latest_incomplete_level
              else
                @current_adventure_level = @adventure_levels.first
                @current_adventure_level_number = @current_adventure_level['level']
                session[:current_adventure_level] = @current_adventure_level_number
              end
            end
          else
            # No session level, show the user's latest unlocked level by default
            if current_user && @latest_incomplete_level
              @current_adventure_level = load_adventure_level(@latest_incomplete_level)
              @current_adventure_level_number = @latest_incomplete_level
              session[:current_adventure_level] = @latest_incomplete_level
            else
              @current_adventure_level = @adventure_levels.first
              @current_adventure_level_number = @current_adventure_level['level']
              session[:current_adventure_level] = @current_adventure_level_number
            end
          end
        end
        
        if @current_adventure_level
          # Check if the current level is completed
          @current_level_completed = current_user ? adventure_level_completed_by_user?(@current_adventure_level_number, current_user) : false
          
          # Prepare puzzle set data for the current level
          @adventure_puzzle_sets = @current_adventure_level['puzzle_sets'].map.with_index do |set_data, index|
            first_puzzle = get_first_puzzle_for_adventure_set(set_data)
            set_data['first_puzzle'] = first_puzzle
            completion_data = current_user ? get_set_completion_data(@current_adventure_level_number, set_data['set_index'], current_user) : nil
            set_data['completed'] = completion_data ? (completion_data['completed'] == true) : false
            set_data['completion_data'] = completion_data
            
            # Determine if this set is unlocked
            # First set is always unlocked, subsequent sets are unlocked if the previous set is completed
            if index == 0
              set_data['unlocked'] = true
            else
              previous_set = @current_adventure_level['puzzle_sets'][index - 1]
              previous_completion_data = current_user ? get_set_completion_data(@current_adventure_level_number, previous_set['set_index'], current_user) : nil
              previous_set_completed = previous_completion_data ? (previous_completion_data['completed'] == true) : false
              set_data['unlocked'] = previous_set_completed
            end
            
            set_data
          end
          
          # Calculate progress for the current level
          @completed_sets_count = @adventure_puzzle_sets.count { |set| set['completed'] }
          @total_sets_count = @adventure_puzzle_sets.length
          
          # Check if there's a next level available
          @next_level_number = @current_adventure_level_number + 1
          @next_level_data = load_adventure_level(@next_level_number)
        else
          # Requested level not found, show first level
          @current_adventure_level = @adventure_levels.first
          @current_adventure_level_number = @current_adventure_level['level']
          @current_level_completed = current_user ? adventure_level_completed_by_user?(@current_adventure_level_number, current_user) : false
          @adventure_puzzle_sets = @current_adventure_level['puzzle_sets'].map.with_index do |set_data, index|
            first_puzzle = get_first_puzzle_for_adventure_set(set_data)
            set_data['first_puzzle'] = first_puzzle
            completion_data = current_user ? get_set_completion_data(@current_adventure_level_number, set_data['set_index'], current_user) : nil
            set_data['completed'] = completion_data ? (completion_data['completed'] == true) : false
            set_data['completion_data'] = completion_data
            
            # Determine if this set is unlocked
            # First set is always unlocked, subsequent sets are unlocked if the previous set is completed
            if index == 0
              set_data['unlocked'] = true
            else
              previous_set = @current_adventure_level['puzzle_sets'][index - 1]
              previous_completion_data = current_user ? get_set_completion_data(@current_adventure_level_number, previous_set['set_index'], current_user) : nil
              previous_set_completed = previous_completion_data ? (previous_completion_data['completed'] == true) : false
              set_data['unlocked'] = previous_set_completed
            end
            
            set_data
          end
          
          # Calculate progress for the current level
          @completed_sets_count = @adventure_puzzle_sets.count { |set| set['completed'] }
          @total_sets_count = @adventure_puzzle_sets.length
          
          # Check if there's a next level available
          @next_level_number = @current_adventure_level_number + 1
          @next_level_data = load_adventure_level(@next_level_number)
        end
        
        @all_adventure_levels_complete = false
      else
        # No adventure levels available
        @current_adventure_level = nil
        @current_adventure_level_number = nil
        @current_level_completed = false
        @adventure_puzzle_sets = []
        @all_adventure_levels_complete = false
      end
    else
      # Adventure mode disabled - set all adventure variables to nil
      @current_adventure_level = nil
      @current_adventure_level_number = nil
      @current_level_completed = false
      @adventure_puzzle_sets = []
      @all_adventure_levels_complete = false
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
    
    adventure_levels = load_adventure_levels
    return nil unless adventure_levels.any?
    
    # Find the first level that is not completed
    adventure_levels.each do |level_data|
      level_number = level_data['level']
      unless adventure_level_completed_by_user?(level_number, user)
        return level_number
      end
    end
    
    # If all levels are completed, return the last level number
    adventure_levels.last['level']
  end

  def load_adventure_levels
    adventure_dir = Rails.root.join("data", "game-modes", "adventure")
    return [] unless Dir.exist?(adventure_dir)
    
    levels = []
    
    # Find all level JSON files
    Dir.glob(adventure_dir.join("level-*.json")).sort.each do |file_path|
      begin
        level_data = JSON.parse(File.read(file_path))
        levels << level_data
      rescue JSON::ParserError => e
        Rails.logger.error "Error parsing adventure level file #{file_path}: #{e.message}"
      end
    end
    
    levels
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

  def load_adventure_puzzle(level_number)
    level = load_adventure_level(level_number)
    return nil unless level && level['puzzle_sets'] && level['puzzle_sets'].any?
    
    first_set = level['puzzle_sets'].first
    return nil unless first_set['puzzles'] && first_set['puzzles'].any?
    
    puzzle_id = first_set['puzzles'].first
    LichessV2Puzzle.find_by(puzzle_id: puzzle_id) || Puzzle.find_by(id: puzzle_id)
  end

  def can_user_access_level?(level_number, user)
    return true unless user # Allow access if no user (guest mode)
    
    adventure_levels = load_adventure_levels
    return false unless adventure_levels.any?
    
    # Find the level data
    level_data = adventure_levels.find { |level| level['level'] == level_number }
    return false unless level_data
    
    # Level 1 is always accessible
    return true if level_number == 1
    
    # For other levels, check if the previous level is completed
    previous_level_number = level_number - 1
    previous_level_data = adventure_levels.find { |level| level['level'] == previous_level_number }
    return false unless previous_level_data
    
    # User can access this level if they completed the previous level
    adventure_level_completed_by_user?(previous_level_number, user)
  end

  def adventure_level_completed_by_user?(level_number, user)
    return false unless user
    
    # Check if all puzzle sets in the level are completed
    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}
    
    # Load the level data to check how many sets it has
    level_data = load_adventure_level(level_number)
    return false unless level_data
    
    # Check if all puzzle sets are completed
    level_data['puzzle_sets'].all? do |set|
      completion_data = level_completions[set['set_index'].to_s]
      completion_data&.is_a?(Hash) && completion_data['completed'] == true
    end
  end

  def get_first_puzzle_for_adventure_set(set_data)
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

  def set_completed_by_user?(level_number, set_index, user)
    return false unless user
    
    # Use user profile to track adventure completions
    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}
    
    completion_data = level_completions[set_index.to_s]
    return false unless completion_data&.is_a?(Hash)
    
    completion_data['completed'] == true
  end

  def get_set_completion_data(level_number, set_index, user)
    return nil unless user

    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}

    completion_data = level_completions[set_index.to_s]

    return nil unless completion_data&.is_a?(Hash)

    completion_data
  end

  def next_level
    level_number = params[:level].to_i
    
    # Check if user can access this level
    if current_user && !can_user_access_level?(level_number, current_user)
      redirect_to "/" and return
    end
    
    # Update session to remember this level
    session[:current_adventure_level] = level_number
    
    # Redirect to homepage with the new level
    redirect_to "/?level=#{level_number}"
  end
end
