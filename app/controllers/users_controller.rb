class UsersController < ApplicationController

  def show
    @user = User.find_by_username(params[:username])
    @attempts = @user&.level_attempts&.group_by(&:level_id) || {}
    @levels = @user.unlocked_levels
  end

end
