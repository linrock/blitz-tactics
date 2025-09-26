class GameModes::AdventureController < ApplicationController
  before_action :authenticate_user!, only: [:complete]

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
    
    # Load puzzles from database using the puzzle IDs
    puzzle_ids = puzzle_set['puzzles']
    @puzzles = []
    
    puzzle_ids.each do |puzzle_id|
      puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
      if puzzle
        @puzzles << puzzle.bt_puzzle_data
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
        success_criteria: "Complete all #{puzzle_set['puzzles_count']} puzzles"
      }
    }
    
    render :play_level
  rescue => e
    Rails.logger.error "Adventure level play error: #{e.message}"
    render plain: "Error loading adventure level", status: :internal_server_error
  end

  def complete
    level_number = params[:level_number].to_i
    set_index = params[:set_index].to_i
    puzzles_solved = params[:puzzles_solved].to_i
    
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
    
    # Check if already completed
    if set_completed_by_user?(level_number, set_index, current_user)
      render json: { 
        success: false, 
        error: "Puzzle set already completed",
        already_completed: true
      }
      return
    end
    
    begin
      # Mark the puzzle set as completed
      mark_set_completed_for_user(level_number, set_index, current_user)
      
      # Check if the entire level is completed
      level_completed = level_completed_by_user?(level_number, current_user)
      
      render json: { 
        success: true,
        set_completed: true,
        level_completed: level_completed,
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
    
    level_completions[set_index.to_s] == true
  end

  def mark_set_completed_for_user(level_number, set_index, user)
    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}
    
    level_completions[set_index.to_s] = true
    adventure_completions[level_number.to_s] = level_completions
    user_profile['adventure_completions'] = adventure_completions
    
    user.update!(profile: user_profile)
  end
end
