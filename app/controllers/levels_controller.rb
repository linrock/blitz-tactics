class LevelsController < ApplicationController
  before_action :authorize_admin!, :only => [:edit, :update]

  def show
    @level = Level.find_by(:slug => level_slug)
    @puzzles = @level.puzzles
    @round_times = current_user&.round_times_for_level(@level.id)&.take(10) || []
    respond_to do |format|
      format.html {}
      format.json {
        render json: {
          puzzles: @puzzles.map(&:simplified_data)
        }
      }
    end
  end

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

  def edit
    @level = Level.find_by(:slug => level_slug)
    @puzzles = @level.puzzles
  end

  def update
    @level = Level.find_by(:slug => level_slug)
    @level.puzzle_ids = params[:puzzle_ids] if params[:puzzle_ids]
    @level.name = params[:name] if params[:name]
    @level.save!
    render partial:    "puzzles/mini_view",
           collection: @level.puzzles,
           as:         :puzzle
  end

  private

  def level_slug
    "level-#{params[:level_num]}"
  end
end
