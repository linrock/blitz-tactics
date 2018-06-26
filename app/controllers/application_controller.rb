class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_sign_up_params, if: :devise_controller?

  protected

  def configure_permitted_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username, :email])
  end

  def set_user
    @user = current_user || NilUser.new
  end

  def require_logged_in_user!
    unless user_signed_in?
      redirect_to new_user_registration_url
    end
  end
end
