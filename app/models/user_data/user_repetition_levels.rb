# for presenting repetition level info for users and nil users

class UserRepetitionLevels

  def initialize(user)
    @user = user # User or NilUser
  end

  def highest_repetition_level_unlocked
    if @user.present?
      level_number = @user.highest_repetition_level_number_completed + 1
    else
      level_number = 1
    end
    RepetitionLevel.number(level_number) || RepetitionLevel.last
  end
end
