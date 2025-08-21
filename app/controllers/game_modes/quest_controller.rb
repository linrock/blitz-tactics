class GameModes::QuestController < ApplicationController
  before_action :authenticate_user!, only: [:complete]
  before_action :find_quest_world_level, only: [:complete]

  def puzzles_json
    @puzzles = LichessV2Puzzle.limit(10).map(&:bt_puzzle_data)
    render json: {
      puzzles: @puzzles
    }
  end

  def show
    @quest_world_level = QuestWorldLevel.find(params[:id])
    
    render json: {
      id: @quest_world_level.id,
      world_id: @quest_world_level.quest_world.id,
      world_description: @quest_world_level.quest_world.description,
      puzzle_ids: @quest_world_level.puzzle_ids,
      puzzle_count: @quest_world_level.puzzle_count,
      puzzles_required: @quest_world_level.puzzles_required,
      time_limit_seconds: @quest_world_level.time_limit_seconds,
      has_time_limit: @quest_world_level.has_time_limit?,
      success_criteria_description: @quest_world_level.success_criteria_description,
      completed: current_user ? @quest_world_level.completed_by?(current_user) : false,
      world_completion_percentage: current_user ? @quest_world_level.quest_world.completion_percentage(current_user) : 0
    }
  rescue ActiveRecord::RecordNotFound
    render json: { 
      error: "Quest level not found" 
    }, status: :not_found
  end

  def edit
    # Check if user has privilege to access this page
    unless privileged_user?
      render plain: "Access denied", status: :forbidden
      return
    end
    
    @quest_worlds = QuestWorld.all.order(:id)
    @quest_worlds_count = @quest_worlds.count
  end

  def edit_quest_world
    # Check if user has privilege to access this page
    unless privileged_user?
      render plain: "Access denied", status: :forbidden
      return
    end
    
    @quest_world = QuestWorld.find(params[:id])
    @quest_world_levels = @quest_world.quest_world_levels.order(:id)
  rescue ActiveRecord::RecordNotFound
    render plain: "Quest world not found", status: :not_found
  end

  def edit_quest_level
    # Check if user has privilege to access this page
    unless privileged_user?
      render plain: "Access denied", status: :forbidden
      return
    end
    
    @quest_level = QuestWorldLevel.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render plain: "Quest level not found", status: :not_found
  end

  def new_quest_level
    # Check if user has privilege to access this page
    unless privileged_user?
      render plain: "Access denied", status: :forbidden
      return
    end
    
    @quest_world = QuestWorld.find(params[:quest_world_id])
    @quest_level = @quest_world.quest_world_levels.build
  rescue ActiveRecord::RecordNotFound
    render plain: "Quest world not found", status: :not_found
  end

  def create_quest_level
    # Check if user has privilege to access this page
    unless privileged_user?
      render plain: "Access denied", status: :forbidden
      return
    end
    
    @quest_world = QuestWorld.find(params[:quest_world_id])
    @quest_level = @quest_world.quest_world_levels.build
    
    # Parse puzzle IDs from form input
    puzzle_ids_input = params[:quest_level][:puzzle_ids_input].to_s.strip
    if puzzle_ids_input.present?
      # Split by comma, space, or newline and clean up
      @quest_level.puzzle_ids = puzzle_ids_input.split(/[\s,\n]+/).reject(&:blank?)
    else
      @quest_level.puzzle_ids = []
    end
    
    # Build success criteria from form inputs
    success_criteria = {}
    puzzles_required = params[:quest_level][:puzzles_required].to_i
    time_limit = params[:quest_level][:time_limit].to_i
    
    # Validate puzzles required
    if puzzles_required <= 0
      @quest_level.errors.add(:puzzles_required, "must be a positive number")
    else
      success_criteria['puzzles_solved'] = puzzles_required
    end
    
    # Validate that we have enough puzzles for the requirement
    if @quest_level.puzzle_ids.length < puzzles_required
      @quest_level.errors.add(:puzzle_ids_input, "must contain at least #{puzzles_required} puzzle IDs (currently has #{@quest_level.puzzle_ids.length})")
    end
    
    # Add time limit if specified
    if time_limit > 0
      success_criteria['time_limit'] = time_limit
    end
    
    @quest_level.success_criteria = success_criteria
    
    # Store form values for redisplay on error
    @form_values = {
      puzzle_ids_input: puzzle_ids_input,
      puzzles_required: puzzles_required,
      time_limit: time_limit > 0 ? time_limit : nil
    }
    
    if @quest_level.save
      redirect_to "/quest/worlds/#{@quest_world.id}/edit", notice: "Quest level created successfully!"
    else
      render :new_quest_level
    end
  rescue ActiveRecord::RecordNotFound
    render plain: "Quest world not found", status: :not_found
  end

  def complete
    # Extract completion data from request
    puzzles_solved = params[:puzzles_solved].to_i
    time_taken = params[:time_taken]&.to_f
    
    # Validate the completion attempt
    unless @quest_world_level.meets_success_criteria?(puzzles_solved, time_taken)
      render json: { 
        success: false, 
        error: "Completion criteria not met",
        required: @quest_world_level.success_criteria_description
      }, status: :unprocessable_entity
      return
    end

    # Check if already completed
    if @quest_world_level.completed_by?(current_user)
      render json: { 
        success: false, 
        error: "Level already completed",
        already_completed: true
      }
      return
    end

    begin
      # Complete the level (this also checks for world completion)
      @quest_world_level.complete_for_user!(current_user)
      
      # Check if the world was completed as a result
      world_completed = @quest_world_level.quest_world.completed_by?(current_user)
      
      render json: { 
        success: true,
        level_completed: true,
        world_completed: world_completed,
        completion_percentage: @quest_world_level.quest_world.completion_percentage(current_user),
        message: world_completed ? "Congratulations! You completed the entire world!" : "Level completed!"
      }
    rescue => e
      Rails.logger.error "Quest completion error: #{e.message}"
      render json: { 
        success: false, 
        error: "Failed to save completion" 
      }, status: :internal_server_error
    end
  end

  private

  def privileged_user?
    Rails.env.development? || (current_user && current_user.id == 1)
  end

  def find_quest_world_level
    @quest_world_level = QuestWorldLevel.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { 
      success: false, 
      error: "Quest level not found" 
    }, status: :not_found
  end
end
