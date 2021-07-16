# repetition mode puzzles

class GameModes::RepetitionController < ApplicationController
  before_action :set_user, only: [:index]
  before_action :set_level

  # show a level in repetition mode
  def index
    unless @level.present?
      redirect_to @user.highest_repetition_level_unlocked.path
      return
    end
    @formatted_round_times = current_user&.round_times_for_level_id(@level.id) || []
    if current_user&.completed_repetition_level?(@level)
      @high_scores = @level.high_scores || []
    else
      @high_scores = []
    end
    render "game_modes/repetition"
  end

  # json endpoint for fetching puzzles
  def puzzles
    render json: {
      puzzles: @level.repetition_puzzles
    }
  end

  # complete a round of puzzles in a level
  def complete_lap
    if user_signed_in?
      current_user.completed_repetition_rounds.create!(
        repetition_round_params.merge(repetition_level_id: @level.id)
      )
    end
    render json: {}
  end

  # successfully complete a level
  def complete_level
    if user_signed_in?
      current_user.completed_repetition_levels.create!(
        repetition_level_id: @level.id
      )
    end
    # TODO handle the very last level
    render json: {
      next: {
        href: @level.next_level.path,
      },
      high_scores: @level.high_scores.map do |user, score|
        [user.username, score]
      end
    }
  end

  private

  def set_level
    if params[:number].present?
      @level = RepetitionLevel.find_by(number: params[:number])
    end
  end

  def repetition_round_params
    params.require(:round).permit(:elapsed_time_ms)
  end
end
