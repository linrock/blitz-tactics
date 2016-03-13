class Api::LevelsController < ApplicationController
  before_filter :set_level
  before_filter :set_user

  def attempt
    if @user
      attempt = @user.level_attempts.find_or_create_by(:level_id => params[:id])
      attempt.update_attribute :last_attempt_at, Time.now
      attempt.completed_rounds.create!(round_params)
    end
    render :json => {}
  end

  def complete
    next_level = @level.next_level
    @user&.unlock_level(next_level.id)
    render :json => { :next => { :href => "/#{next_level.slug}" } }
  end

  private

  def round_params
    params.require(:round).permit(:time_elapsed, :errors_count)
  end

  def set_level
    @level = Level.find(params[:id])
  end

  def set_user
    @user = current_user
  end

end
