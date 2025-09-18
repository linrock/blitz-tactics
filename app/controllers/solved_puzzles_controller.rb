class SolvedPuzzlesController < ApplicationController
  before_action :authenticate_user!

  def create
    SolvedPuzzle.track_solve(current_user.id, params[:puzzle_id], params[:game_mode])
    render json: { status: 'success' }
  rescue => e
    Rails.logger.error "Failed to track solved puzzle: #{e.message}"
    render json: { status: 'error', message: e.message }, status: 422
  end
end