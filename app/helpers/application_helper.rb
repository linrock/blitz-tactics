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

  def sound_enabled?
    if user_signed_in?
      current_user.sound_enabled?
    else
      session[:sound_enabled].nil? || session[:sound_enabled]  == true
    end
  end

  def titleize_theme(theme)
    return nil if theme.nil?
    
    # Handle different word boundary patterns
    words = theme.split('_').flat_map do |part|
      # Split camelCase into separate words
      part = part.gsub(/([a-z])([A-Z])/, '\1 \2')
      
      # Split common chess theme patterns (e.g., "defensivemove" -> "defensive move")
      # This handles cases where words are concatenated without separators
      part = part.gsub(/([a-z])(move|mate|fork|pin|sacrifice|endgame|opening|tactic|pattern)$/, '\1 \2')
      part = part.gsub(/^(defensive|offensive|back|queen|king|knight|bishop|rook|pawn)([a-z])/, '\1 \2')
      
      part.split(' ')
    end
    
    words.map(&:capitalize).join(' ')
  end
end
