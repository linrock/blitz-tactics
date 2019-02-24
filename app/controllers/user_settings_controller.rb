# sound on/off

class UserSettingsController < ApplicationController

  def update
    if user_signed_in?
      current_user.set_sound_enabled settings_params[:sound_enabled]
    else
      session[:sound_enabled] = settings_params[:sound_enabled]
    end
  end

  private

  def settings_params
    params.require(:settings).permit(:sound_enabled)
  end
end
