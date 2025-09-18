# for presenting rook endgames info for users and nil users

class UserRookEndgamesRounds

  def initialize(user)
    @user = user # User or NilUser
  end

  def best_rook_endgames_score(date)
    return 'None' if !@user.present?
    @user.completed_rook_endgames_rounds.personal_best(date) or 'None'
  end
end