class LevelsController < ApplicationController
  before_action :authorize_admin!, only: [:edit, :update]
  before_action :set_level, except: :index

  def index
    @unlocked = current_user&.unlocked_levels || []
    @levels = Level.all.order("id ASC")
    if @unlocked.size < 10
      @levels = @levels.limit(20)
    elsif @unlocked.size < 25
      @levels = @levels.limit(35)
    end
    @attempts = current_user&.level_attempts&.group_by(&:level_id) || {}
  end

  # show a level in repetition mode
  def show
    @puzzles = @level.puzzles
    @round_times = current_user&.round_times_for_level(@level.id)&.take(10) || []
    respond_to do |format|
      format.html {}
      format.json {
        render json: PuzzlesJson.new(@puzzles).to_json
      }
    end
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

  # level editor view
  def edit
    @puzzles = @level.puzzles
  end

  # updating the puzzles in a level or the name of the level
  def update
    @level.puzzle_ids = params[:puzzle_ids] if params[:puzzle_ids]
    @level.name = params[:name] if params[:name]
    @level.save!
    render partial: "puzzles/mini_view", collection: @level.puzzles, as: :puzzle
  end

  private

  def set_level
    @level = Level.by_number(params[:level_num])
  end

  def round_params
    params.require(:round).permit(:time_elapsed, :errors_count)
  end
end
