module ApplicationHelper

  def https_registration_url
    if Rails.env.production?
      new_user_registration_url(:protocol => "https")
    else
      new_user_registration_path
    end
  end

  def https_login_url
    if Rails.env.production?
      new_user_session_url(:protocol => "https")
    else
      new_user_session_path
    end
  end
end
