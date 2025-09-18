# for presenting openings info for users and nil users

class UserOpeningsRounds

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_openings_score(date)
    return 'None' if !@user.present?
    @user.completed_openings_rounds.personal_best(date) or 'None'
  end
end
