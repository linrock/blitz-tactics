# user's external profile page

class UsersController < ApplicationController

  def show
    @user = User.find_by_username(params[:username])
    unless @user.present?
      render "pages/not_found", status: 404
      return
    end
    if @user == current_user
      render "users/me"
      return
    end
  end
end
