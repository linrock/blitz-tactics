module ApplicationHelper

  def user_link(user)
    link_to user.username, "/#{user.username}", class: "username"
  end

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
