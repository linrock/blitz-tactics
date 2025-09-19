# user's external profile page

class UsersController < ApplicationController
  before_action :set_request_format, only: [:show]
  before_action :require_logged_in_user!,
    only: [:update, :customize_board, :update_board, :preferences, :destroy]

  def show
    @user = User.find_by_username(params[:username])
    unless @user.present?
      render "pages/not_found", status: 404
      return
    end
    
    # Load recent solved puzzles for both show and me views
    load_recent_solved_puzzles
    
    if @user == current_user
      render "users/me"
      return
    end
  end

  # GET /preferences
  def preferences
  end

  # DELETE /account
  def destroy
    password = params[:current_password].to_s
    unless current_user.valid_password?(password)
      redirect_back fallback_location: preferences_path, alert: 'Incorrect password. Account not deleted.'
      return
    end

    current_user.destroy!
    sign_out(:user)
    redirect_to root_path, notice: 'Your account has been deleted.'
  end

  # when user sets a tagline
  def update
    current_user.update! user_params
    redirect_back fallback_location: root_url
  end

  # GET /customize - customize user chessboard
  def customize_board
    @board = current_user.user_chessboard
    @haste_puzzle = HastePuzzle.random
  end

  # PUT /customize - update user chessboard
  def update_board
    board = current_user.user_chessboard || current_user.build_user_chessboard
    board.update! board_params
    redirect_to "/customize", notice: "Board customization saved!"
  end

  private

  def load_recent_solved_puzzles
    # Get the last 6 puzzles solved by the user from the simple tracking system
    if @user.present?
      recent_puzzle_data = SolvedPuzzle.recent_with_details(@user.id, 6)
      
      # Get the puzzle data for each solved puzzle, with fallback to legacy Puzzle model
      @recent_puzzles = recent_puzzle_data.map do |puzzle_data|
        # Try LichessV2Puzzle first, then fall back to legacy Puzzle model
        puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_data[:puzzle_id]) ||
                 Puzzle.find_by(id: puzzle_data[:puzzle_id])
        
        if puzzle
          # Handle different puzzle models (LichessV2Puzzle vs legacy Puzzle)
          if puzzle.is_a?(LichessV2Puzzle)
            {
              puzzle: puzzle,
              puzzle_data: puzzle.bt_puzzle_data,
              solution_lines: puzzle.lines_tree,
              solved_at: puzzle_data[:solved_at],
              game_mode: puzzle_data[:game_mode]
            }
          else
            # Legacy Puzzle model
            {
              puzzle: puzzle,
              puzzle_data: puzzle.bt_puzzle_data,
              solution_lines: puzzle.puzzle_data["lines"],
              solved_at: puzzle_data[:solved_at],
              game_mode: puzzle_data[:game_mode]
            }
          end
        else
          nil
        end
      end.compact
    else
      @recent_puzzles = []
    end
  end

  def user_params
    params.require(:user).permit(:tagline)
  end

  def board_params
    params.require(:board).permit(
      :light_square_color,
      :dark_square_color,
      :opponent_from_square_color,
      :opponent_to_square_color,
      :selected_square_color,
      :piece_set
    )
  end

  def set_request_format
    request.format = :html
  end
end
