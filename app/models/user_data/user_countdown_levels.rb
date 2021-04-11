# for presenting countdown info for users and nil users

class UserCountdownLevels

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_countdown_score(countdown_level)
    return 'None' if !@user.present? or !countdown_level
    @user.completed_countdown_levels
      .where(countdown_level_id: countdown_level.id)
      .maximum(:score) or 'None'
  end
end
