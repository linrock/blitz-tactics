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

  def safe_piece_asset_path(piece_set, piece_code)
    begin
      asset_path("pieces/#{piece_set}/#{piece_code}.svg")
    rescue Propshaft::MissingAssetError
      # Handle special cases for piece sets with different naming conventions
      case piece_set
      when 'mono'
        # mono uses single letter naming (N.svg instead of wN.svg/bN.svg)
        single_letter = piece_code[1] # Extract 'N' from 'wN' or 'bN'
        asset_path("pieces/#{piece_set}/#{single_letter}.svg")
      else
        # Fallback to cburnett (standard) piece set
        asset_path("pieces/cburnett/#{piece_code}.svg")
      end
    end
  end

  # Feature flag helper methods
  def feature_enabled?(feature_name)
    FeatureFlag.enabled?(feature_name)
  end

  def feature_disabled?(feature_name)
    !FeatureFlag.enabled?(feature_name)
  end

  # Helper for conditional rendering based on feature flags
  def with_feature(feature_name, &block)
    if FeatureFlag.enabled?(feature_name)
      capture(&block)
    end
  end

  # Helper for rendering different content based on feature flags
  def feature_toggle(feature_name, enabled_content: nil, disabled_content: nil, &block)
    if FeatureFlag.enabled?(feature_name)
      if enabled_content
        enabled_content
      elsif block_given?
        capture(&block)
      end
    else
      disabled_content
    end
  end
end
