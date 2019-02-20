class UserRating < ApplicationRecord
  has_many :rated_puzzle_attempts
end
