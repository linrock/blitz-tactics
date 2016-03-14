class LevelsController < ApplicationController

  def show
    @level = Level.find_by(:slug => params[:level_slug])
    @puzzles = @level.puzzles
    @round_times = current_user&.round_times_for_level(@level.id) || []
    respond_to do |format|
      format.html {}
      format.json {
        render :json => {
          :format  => 'lichess',
          :puzzles => @puzzles.map(&:data)
        }
      }
    end
  end

  def index
    @levels = Level.all.order("id ASC")
    @unlocked = current_user&.unlocked_levels
    @attempts = current_user&.level_attempts&.group_by(&:level_id) || {}
  end

end
