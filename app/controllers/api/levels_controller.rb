class Api::LevelsController < ApplicationController
  before_filter :set_level
  before_filter :set_user

  def attempt
    if @user
      params[:id]
      @user.level_attempts
    end
    render :json => {}
  end

  def complete
    next_level = @level.next_level
    @user&.unlock_level(next_level.id)
    render :json => { :next => { :href => "/#{next_level.slug}" } }
  end

  private

  def set_level
    @level = Level.find(params[:id])
  end

  def set_user
    @user = current_user
  end

end
