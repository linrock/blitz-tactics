# user's external profile page

class UsersController < ApplicationController

  def show
    @user = User.find_by_username(params[:username])
    if @user == current_user
      render "users/me"
      return
    end
  end
end
