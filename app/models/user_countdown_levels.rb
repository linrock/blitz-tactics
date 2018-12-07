# for presenting countdown info for users and nil users

class UserCountdownLevels

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_countdown_score(countdown_level)
    if @user.present?
      @user.completed_countdown_levels
        .where(countdown_level_id: countdown_level.id)
        .maximum(:score) rescue 'None'
    else
      'None'
    end
  end
end
