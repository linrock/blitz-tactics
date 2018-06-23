# repetition mode puzzles

class GameModes::RepetitionController < ApplicationController
  before_action :set_level, only: [:index, :puzzles]

  # show a level in repetition mode
  def index
    @round_times = current_user&.round_times_for_level(@level.id)&.take(10) || []
    render "game_modes/repetition"
  end

  # json endpoint for fetching puzzles
  def puzzles
    @puzzles = @level.puzzles
    render json: PuzzlesJson.new(@puzzles).to_json
  end

  # complete a round of puzzles in a level
  def attempt
    if @user
      attempt = @user.level_attempts.find_or_create_by(level_id: params[:id])
      attempt.update_attribute :last_attempt_at, Time.now
      attempt.completed_rounds.create(round_params)
    end
    render json: {}
  end

  # successfully complete a level
  def complete
    next_level = Level.find(params[:id]).next_level
    # TODO handle the very last level
    @user&.unlock_level(next_level.id)
    render json: {
      next: {
        href: next_level.path
      }
    }
  end

  private

  def set_level
    @level = Level.by_number(params[:level_num])
  end

  def round_params
    params.require(:round).permit(:time_elapsed, :errors_count)
  end
end
