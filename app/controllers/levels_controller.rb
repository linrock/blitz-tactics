class LevelsController < ApplicationController
  before_filter :authorize_admin!, :only => [:edit, :update]

  def show
    @level = Level.find_by(:slug => params[:level_slug])
    @puzzles = @level.puzzles
    @round_times = current_user&.round_times_for_level(@level.id)&.take(10) || []
    respond_to do |format|
      format.html {}
      format.json {
        render :json => {
          :puzzles => @puzzles.map(&:simplified_data)
        }
      }
    end
  end

  def index
    @levels = Level.all.order("id ASC")
    @unlocked = current_user&.unlocked_levels
    @attempts = current_user&.level_attempts&.group_by(&:level_id) || {}
  end

  def edit
    @level = Level.find_by(:slug => params[:level_slug])
    @puzzles = @level.puzzles
  end

  def update
    @level = Level.find_by(:slug => params[:level_slug])
    @level.puzzle_ids = params[:puzzle_ids] if params[:puzzle_ids]
    @level.name = params[:name] if params[:name]
    @level.save!
    render :partial    => "puzzles/mini_view",
           :collection => @level.puzzles,
           :as         => :puzzle
  end

end
