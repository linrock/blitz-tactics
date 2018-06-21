# user's external profile page

class UsersController < ApplicationController

  def show
    @user = User.find_by_username(params[:username])
    @attempts = @user&.level_attempts&.group_by(&:level_id) || {}
    @level_numbers = @user.unlocked_levels
  end
end
