# delegate methods common to users and nil users

require 'active_support/concern'

module UserDelegates
  extend ActiveSupport::Concern

  included do
    delegate :next_infinity_puzzle,
             :next_infinity_puzzle_set,
             to: :user_infinity_puzzles

    private

    def user_infinity_puzzles
      UserInfinityPuzzles.new(self)
    end
  end
end
