# anonymous users

class NilUser
  delegate :next_infinity_puzzle,
           :next_infinity_puzzle_set,
           to: :user_infinity_puzzles

  def present?
    false
  end

  private

  def user_infinity_puzzles
    @user_infinity_puzzles ||= UserInfinityPuzzles.new(nil)
  end
end
