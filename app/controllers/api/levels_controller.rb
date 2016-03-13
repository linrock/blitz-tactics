class Api::LevelsController < ApplicationController
  before_filter :set_user

  def attempt
    if @profile
      params[:id]
    end
    render :json => {}
  end

  def complete
    if @profile
      params[:id]
    end
    render :json => {}
  end

  private

  def set_user_profile
    @user = current_user
  end

end
