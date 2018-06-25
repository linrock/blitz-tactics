# repetition mode puzzles

class GameModes::RepetitionController < ApplicationController
  before_action :set_level

  # show a level in repetition mode
  def index
    unless @level.present?
      @level = current_user ? current_user.highest_level_unlocked : Level.by_number(1)
      redirect_to @level.path
      return
    end
    @round_times = current_user&.round_times_for_level(@level.id)&.take(10) || []
    render "game_modes/repetition"
  end

  # json endpoint for fetching puzzles
  def puzzles
    render json: {
      puzzles: @level.puzzles.map(&:simplified_data)
    }
  end

  # complete a round of puzzles in a level
  def attempt
    if current_user
      attempt = current_user.level_attempts.find_or_create_by(level_id: @level.id)
      attempt.update_attribute :last_attempt_at, Time.now
      attempt.completed_rounds.create(round_params)
    end
    render json: {}
  end

  # successfully complete a level
  def complete
    next_level = @level.next_level
    # TODO handle the very last level
    current_user&.unlock_level(next_level.number)
    render json: {
      next: {
        href: next_level.path
      }
    }
  end

  private

  def set_level
    @level = Level.by_number(params[:number]) if params[:number].present?
  end

  def round_params
    params.require(:round).permit(:time_elapsed, :errors_count)
  end
end
