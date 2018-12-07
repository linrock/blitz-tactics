# for presenting countdown info for users and nil users

class UserCountdowns

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_countdown_time(countdown_level)
    if @user.present?
      @user.completed_countdowns
        .where(countdown_level_id: countdown_level.id).formatted_fastest_time
    else
      'None'
    end
  end
end
