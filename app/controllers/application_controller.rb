class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?

  def is_responsive
    @responsive = true
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :username
  end

  def authorize_admin!
    unless current_user && current_user.id == 1
      raise ActionController::RoutingError.new('Not Found')
      return
    end
  end

  def require_logged_in_user!
    unless current_user
      redirect_to new_user_registration_url
    end
  end

end
