class GameModes::AdventureController < ApplicationController
  before_action :authenticate_user!, only: [:complete]

  def index
    # Load all adventure levels
    @adventure_levels = []
    
    # Load levels 1-100
    (1..100).each do |level_number|
      level_data = load_adventure_level(level_number)
      if level_data
        # Check if user can access this level (unlocked)
        can_access = can_user_access_level?(level_number, current_user)
        
        # Only include levels that are unlocked
        if can_access
          # Check completion status for current user
          completed = current_user ? level_completed_by_user?(level_number, current_user) : false
          
          # Get best times for each puzzle set in this level
          best_times = []
          if current_user
            level_data['puzzle_sets'].each do |set|
              completion_data = get_set_completion_data(level_number, set['set_index'], current_user)
              if completion_data && completion_data['best_time_ms']
                best_times << {
                  set_index: set['set_index'],
                  best_time_ms: completion_data['best_time_ms']
                }
              end
            end
          end
          
          @adventure_levels << {
            level_number: level_number,
            data: level_data,
            completed: completed,
            best_times: best_times
          }
        end
      end
    end
    
    # Sort from latest level to earliest (highest level number first)
    @adventure_levels.sort_by! { |level| -level[:level_number] }
    
    render :index
  end

  def show
    level_number = params[:level_number].to_i
    
    # Load adventure level data from JSON file
    level_data = load_adventure_level(level_number)
    
    if level_data.nil?
      render plain: "Adventure level #{level_number} not found", status: :not_found
      return
    end
    
    respond_to do |format|
      format.html do
        # Prepare puzzle data for rendering mini boards
        @level_data = level_data
        @puzzle_sets = level_data['puzzle_sets']
        @total_puzzle_count = @puzzle_sets.sum { |set| set['puzzles_count'] }
        render :show
      end
      format.json do
        render json: {
          level: level_data['level'],
          description: level_data['description'],
          rating_range: level_data['rating_range'],
          puzzle_sets: level_data['puzzle_sets'],
          total_puzzles: @puzzle_sets.sum { |set| set['puzzles_count'] },
          completed: current_user ? level_completed_by_user?(level_number, current_user) : false
        }
      end
    end
  end

  def play_level
    level_number = params[:level_number].to_i
    set_index = params[:set_index].to_i
    
    # Load adventure level data
    level_data = load_adventure_level(level_number)
    
    if level_data.nil?
      render plain: "Adventure level #{level_number} not found", status: :not_found
      return
    end
    
    # Find the specific puzzle set
    puzzle_set = level_data['puzzle_sets'].find { |set| set['set_index'] == set_index }
    
    if puzzle_set.nil?
      render plain: "Puzzle set #{set_index} not found in level #{level_number}", status: :not_found
      return
    end
    
    # Handle checkmate challenges differently - they use position_fen instead of puzzles
    if puzzle_set['challenge'] == 'checkmate'
      @puzzles = []
      # For checkmate challenges, we don't need puzzle data - the frontend will handle the position
    else
      # Load puzzles from database using the puzzle IDs
      puzzle_ids = puzzle_set['puzzles']
      @puzzles = []
      
      puzzle_ids.each do |puzzle_id|
        puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
        if puzzle
          @puzzles << puzzle.bt_puzzle_data
        end
      end
    end
    
    # Set up puzzle player data
    @puzzle_data = {
      puzzles: @puzzles,
      level_info: {
        level_number: level_number,
        level_description: level_data['description'],
        set_index: set_index,
        color_to_move: puzzle_set['color_to_move'],
        rating_range: puzzle_set['rating_range'],
        puzzle_count: puzzle_set['puzzles_count'], # Required puzzles to solve
        puzzles_in_pool: @puzzles.length, # Total puzzles in pool
        challenge: puzzle_set['challenge'],
        challenge_description: puzzle_set['challenge_description'],
        combo_target: puzzle_set['combo_target'],
        combo_drop_time: puzzle_set['combo_drop_time'],
        time_limit: puzzle_set['challenge_config']&.dig('time_limit'), # Time limit in seconds
        success_criteria: "Complete all #{puzzle_set['puzzles_count']} puzzles"
      }
    }
    
    # Add position data for checkmate challenges
    if puzzle_set['challenge'] == 'checkmate'
      @puzzle_data[:position_fen] = puzzle_set['position_fen']
      @puzzle_data[:level_info][:position_fen] = puzzle_set['position_fen']
    end
    
    render :play_level
  rescue => e
    Rails.logger.error "Adventure level play error: #{e.message}"
    render plain: "Error loading adventure level", status: :internal_server_error
  end

  def complete
    level_number = params[:level_number].to_i
    set_index = params[:set_index].to_i
    puzzles_solved = params[:puzzles_solved].to_i
    time_spent = params[:time_spent]&.to_i # Time in milliseconds
    
    # Load adventure level data to validate completion
    level_data = load_adventure_level(level_number)
    
    if level_data.nil?
      render json: { 
        success: false, 
        error: "Adventure level not found" 
      }, status: :not_found
      return
    end
    
    # Find the specific puzzle set
    puzzle_set = level_data['puzzle_sets'].find { |set| set['set_index'] == set_index }
    
    if puzzle_set.nil?
      render json: { 
        success: false, 
        error: "Puzzle set not found" 
      }, status: :not_found
      return
    end
    
    # Check if completion criteria is met (all puzzles solved)
    required_puzzles = puzzle_set['puzzles_count']
    
    unless puzzles_solved >= required_puzzles
      render json: { 
        success: false, 
        error: "Completion criteria not met",
        required: "Solve all #{required_puzzles} puzzles",
        solved: puzzles_solved
      }, status: :unprocessable_entity
      return
    end
    
    
    begin
      # Mark the puzzle set as completed and get the completion data
      completion_data = mark_set_completed_for_user(level_number, set_index, current_user, time_spent)
      
      # Check if the entire level is completed
      level_completed = level_completed_by_user?(level_number, current_user)
      
      # Get the best time from the completion data we just created
      best_time_ms = completion_data&.dig('best_time_ms')
      
      render json: { 
        success: true,
        set_completed: true,
        level_completed: level_completed,
        best_time_ms: best_time_ms,
        message: level_completed ? "Congratulations! You completed the entire level!" : "Puzzle set completed!"
      }
    rescue => e
      Rails.logger.error "Adventure completion error: #{e.message}"
      render json: { 
        success: false, 
        error: "Failed to save completion" 
      }, status: :internal_server_error
    end
  end

  private

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

  def level_completed_by_user?(level_number, user)
    return false unless user
    
    # Check if all puzzle sets in the level are completed
    level_data = load_adventure_level(level_number)
    return false unless level_data
    
    level_data['puzzle_sets'].all? do |set|
      set_completed_by_user?(level_number, set['set_index'], user)
    end
  end

  def set_completed_by_user?(level_number, set_index, user)
    return false unless user
    
    # Use user profile to track adventure completions
    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}
    
    completion_data = level_completions[set_index.to_s]
    return false unless completion_data.is_a?(Hash)
    
    completion_data['completed'] == true
  end

  def mark_set_completed_for_user(level_number, set_index, user, time_spent = nil)
    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}
    
    current_time = Time.current.iso8601
    existing_data = level_completions[set_index.to_s]
    
    # Initialize completion data
    completion_data = {
      'completed' => true
    }
    
    # Handle existing completion data
    if existing_data.is_a?(Hash)
      # Update existing data
      completion_data = existing_data.dup
      completion_data['completed'] = true
      
      # Update best time if this is faster
      if time_spent && time_spent > 0
        current_best = completion_data['best_time_ms']
        if current_best.nil? || time_spent < current_best
          completion_data['best_time_ms'] = time_spent
        end
      end
    else
      # First completion
      completion_data['first_completed_at'] = current_time
      
      # Set best time if provided
      if time_spent && time_spent > 0
        completion_data['best_time_ms'] = time_spent
      end
    end
    
    level_completions[set_index.to_s] = completion_data
    adventure_completions[level_number.to_s] = level_completions
    user_profile['adventure_completions'] = adventure_completions
    
    user.update!(profile: user_profile)
    
    # Return the completion data so we can access best_time_ms
    completion_data
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

  def can_user_access_level?(level_number, user)
    return true unless user # Allow access if no user (guest mode)
    
    # Level 1 is always accessible
    return true if level_number == 1
    
    # For other levels, check if the previous level is completed
    previous_level_number = level_number - 1
    previous_level_data = load_adventure_level(previous_level_number)
    return false unless previous_level_data
    
    # User can access this level if they completed the previous level
    level_completed_by_user?(previous_level_number, user)
  end
end
