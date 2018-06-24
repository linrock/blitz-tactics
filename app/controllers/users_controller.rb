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

  # when user sets a tagline
  def update
    current_user.update_attributes! user_params
    redirect_back fallback_location: root_url
  end

  private

  def user_params
    params.require(:user).permit(:tagline)
  end
end
