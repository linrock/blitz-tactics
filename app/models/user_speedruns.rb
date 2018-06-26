# for presenting speedrun info for users and nil users

class UserSpeedruns

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_speedrun_time
    if @user.present?
      @user.completed_speedruns.formatted_fastest_time
    else
      'None'
    end
  end
end
