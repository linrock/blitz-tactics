# for presenting haste info for users and nil users

class UserHasteRounds

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_haste_score(date)
    return 'None' if !@user.present?
    @user.completed_haste_rounds.personal_best(date) or 'None'
  end
end
