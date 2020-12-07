# for presenting countdown info for users and nil users

class UserThreesRounds

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_threes_score(date)
    return 'None' unless @user.present?
    @user.completed_threes_rounds.personal_best(date) or 'None'
  end
end
