class UserRating < ActiveRecord::Base
  has_many :rated_puzzle_attempts

  after_initialize :initialize_glicko2_rating

  validates :initial_rating, presence: true
  validates :initial_rating_deviation, presence: true
  validates :initial_rating_volatility, presence: true

  validates :rating, presence: true
  validates :rating_deviation, presence: true
  validates :rating_volatility, presence: true

  private

  def initialize_glicko2_rating
    return if initial_rating.present?
    self.initial_rating = 1500
    self.initial_rating_deviation = 350
    self.initial_rating_volatility = 0.6
    self.rating = self.initial_rating
    self.rating_deviation = self.initial_rating_deviation
    self.rating_volatility = self.initial_rating_volatility
  end
end
