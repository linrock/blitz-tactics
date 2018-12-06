# for presenting speedrun info for users and nil users

class UserSpeedruns

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_speedrun_time(speedrun_level)
    if @user.present?
      @user.completed_speedruns
        .where(speedrun_level_id: speedrun_level.id).formatted_fastest_time
    else
      'None'
    end
  end
end
