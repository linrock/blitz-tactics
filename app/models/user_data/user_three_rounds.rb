# for presenting three rounds info for users and nil users

class UserThreeRounds

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_three_score(date)
    return 'None' unless @user.present?
    @user.completed_three_rounds.personal_best(date) or 'None'
  end
end
