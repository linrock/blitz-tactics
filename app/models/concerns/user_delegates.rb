# delegate methods common to users and nil users

require 'active_support/concern'

module UserDelegates
  extend ActiveSupport::Concern

  included do
    delegate :next_infinity_puzzle,
             :next_infinity_puzzle_set, to: :user_infinity_puzzles

    delegate :best_speedrun_time, to: :user_speedruns

    delegate :highest_repetition_level_unlocked, to: :user_repetition_levels

    private

    def user_infinity_puzzles
      UserInfinityPuzzles.new(self)
    end

    def user_speedruns
      UserSpeedruns.new(self)
    end

    def user_countdowns
      UserCountdowns.new(self)
    end

    def user_repetition_levels
      UserRepetitionLevels.new(self)
    end
  end
end
