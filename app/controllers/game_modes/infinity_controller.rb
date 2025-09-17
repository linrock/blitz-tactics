# infinity mode puzzles

class GameModes::InfinityController < ApplicationController
  before_action :set_user

  def index
    # Get the last 5 infinity puzzles solved by the user with timing info
    if current_user
      @recent_solved_puzzles = @user.solved_infinity_puzzles.
        order('updated_at DESC').limit(5).
        includes(:infinity_puzzle)
      
      # Get the puzzle data for each solved puzzle
      @recent_puzzles = @recent_solved_puzzles.map do |solved|
        puzzle_id = solved.infinity_puzzle.data['id']
        
        # Try to find in LichessV2Puzzle first
        puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
        if puzzle
          {
            puzzle: puzzle,
            puzzle_data: puzzle.bt_puzzle_data,
            solution_lines: puzzle.lines_tree,
            solved_at: solved.updated_at,
            difficulty: solved.difficulty
          }
        else
          # Fallback to legacy Puzzle model
          puzzle = Puzzle.find_by(id: puzzle_id)
          if puzzle
            {
              puzzle: puzzle,
              puzzle_data: puzzle.bt_puzzle_data,
              solution_lines: puzzle.puzzle_data["lines"],
              solved_at: solved.updated_at,
              difficulty: solved.difficulty
            }
          else
            nil
          end
        end
      end.compact
    else
      @recent_puzzles = []
    end
    
    render "game_modes/infinity"
  end

  # json endpoint for fetching puzzles
  def puzzles_json
    render json: @user.next_infinity_puzzle_set(
      params[:difficulty],
      params[:after_puzzle_id]
    )
  end

  # shows a list of puzzles you've seen recently
  def puzzles
    if current_user
      @per_page = 30
      @page = params[:page].to_i
      @page = 1 if @page < 1
      @offset = (@page - 1) * @per_page
      
      solved_puzzle_ids = @user.solved_infinity_puzzles.
        order('id DESC').limit(@per_page).offset(@offset).
        includes(:infinity_puzzle).
        map do |solved|
          solved.infinity_puzzle.data['id']
        end
      @puzzles = Puzzle.find_by_sorted(solved_puzzle_ids)
      
      # Calculate total count and pages for pagination
      @total_count = @user.solved_infinity_puzzles.count
      @total_pages = (@total_count.to_f / @per_page).ceil
      @has_next_page = @page < @total_pages
      @has_prev_page = @page > 1
    else
      @puzzles = []
      @per_page = 30
      @page = 1
      @total_count = 0
      @total_pages = 0
      @has_next_page = false
      @has_prev_page = false
    end
  end

  # notifying server of status updates in infinity mode
  def puzzle_solved
    if @user.present?
      Rails.logger.info "=== PUZZLE SOLVED REQUEST ==="
      Rails.logger.info "solved_puzzle_params: #{solved_puzzle_params.inspect}"
      
      solved_puzzle = @user.solved_infinity_puzzles.find_by(
        solved_puzzle_params
      )
      if solved_puzzle.present?
        Rails.logger.info "Found existing solved puzzle: #{solved_puzzle.id}, touching it"
        solved_puzzle.touch
      else
        Rails.logger.info "Creating new solved puzzle record"
        @user.solved_infinity_puzzles.create!(solved_puzzle_params)
      end
      render json: { n: @user.solved_infinity_puzzles.count }
    else
      render json: {}
    end
  end

  # Get recent puzzles for the list view
  def recent_puzzles
    if current_user
      recent_solved_puzzles = @user.solved_infinity_puzzles.
        order('id DESC').limit(5).
        includes(:infinity_puzzle)
      
      recent_puzzles = recent_solved_puzzles.map do |solved|
        puzzle = Puzzle.find_by(id: solved.infinity_puzzle.data['id'])
        if puzzle
          {
            puzzle: puzzle.bt_puzzle_data,
            solved_at: solved.created_at,
            difficulty: solved.difficulty
          }
        else
          nil
        end
      end.compact
      
      render json: { puzzles: recent_puzzles }
    else
      render json: { puzzles: [] }
    end
  end

  def recent_puzzle_item
    puzzle_id = params[:puzzle_id]
    difficulty = params[:difficulty]
    
    Rails.logger.info "=== RECENT PUZZLE ITEM REQUEST ==="
    Rails.logger.info "puzzle_id: #{puzzle_id} (type: #{puzzle_id.class})"
    Rails.logger.info "difficulty: #{difficulty}"
    
    if current_user && puzzle_id && difficulty
      # The puzzle_id should be an InfinityPuzzle database ID
      Rails.logger.info "Looking for InfinityPuzzle with id: #{puzzle_id}"
      infinity_puzzle = InfinityPuzzle.find_by(id: puzzle_id)
      Rails.logger.info "InfinityPuzzle search result: #{infinity_puzzle ? 'found' : 'not found'}"
      
      if infinity_puzzle
        Rails.logger.info "Found InfinityPuzzle: #{infinity_puzzle.inspect}"
        lichess_puzzle_id = infinity_puzzle.data['id']
        Rails.logger.info "Lichess puzzle ID from data: #{lichess_puzzle_id}"
        
        # Try to find the actual puzzle data by Lichess puzzle ID first
        puzzle = LichessV2Puzzle.find_by(puzzle_id: lichess_puzzle_id)
        Rails.logger.info "LichessV2Puzzle search result: #{puzzle ? 'found' : 'not found'}"
        
        if puzzle
          puzzle_data = {
            puzzle: puzzle,
            puzzle_data: puzzle.bt_puzzle_data,
            solution_lines: puzzle.lines_tree,
            solved_at: Time.current,
            difficulty: difficulty
          }
        else
          # Fallback to legacy Puzzle model
          Rails.logger.info "Trying legacy Puzzle model with id: #{lichess_puzzle_id}"
          puzzle = Puzzle.find_by(id: lichess_puzzle_id)
          Rails.logger.info "Legacy Puzzle search result: #{puzzle ? 'found' : 'not found'}"
          
          if puzzle
            puzzle_data = {
              puzzle: puzzle,
              puzzle_data: puzzle.bt_puzzle_data,
              solution_lines: puzzle.puzzle_data["lines"],
              solved_at: Time.current,
              difficulty: difficulty
            }
          else
            render nothing: true, status: 404
            return
          end
        end
      else
        render nothing: true, status: 404
        return
      end
      
      # Get the current number of recent puzzles to determine the puzzle number
      puzzle_number = @user.solved_infinity_puzzles.count % 5 + 1
      
      render partial: 'recent_puzzle_item', locals: { 
        puzzle_data: puzzle_data, 
        puzzle_number: puzzle_number 
      }
    else
      render nothing: true, status: 404
    end
  end

  private

  def solved_puzzle_params
    p_params = params.require(:puzzle).permit(:difficulty, :puzzle_id).to_h
    p_params["infinity_puzzle_id"] = p_params["puzzle_id"]
    p_params.delete("puzzle_id")
    p_params
  end
end
