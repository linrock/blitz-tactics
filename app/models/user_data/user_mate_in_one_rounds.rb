# for presenting mate-in-one info for users and nil users

class UserMateInOneRounds

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_mate_in_one_score(date)
    return 'None' if !@user.present?
    @user.completed_mate_in_one_rounds.personal_best(date) or 'None'
  end
end
