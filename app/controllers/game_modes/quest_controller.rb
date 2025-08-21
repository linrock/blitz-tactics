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
