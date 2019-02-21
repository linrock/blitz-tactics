require 'rails_helper'

describe RatedPuzzleAttempt do
  Rating = Struct.new(:rating, :rating_deviation, :volatility)

  let(:user) {
    User.create!(username: "user", password: "password")
  }

  it 'modifies ratings based on win/loss/draw' do
    # player 1 wins vs. player 2
    rating1 = Rating.new(1400, 30, 0.06)
    rating2 = Rating.new(1550, 100, 0.06)
    period = Glicko2::RatingPeriod.from_objs [rating1, rating2]
    period.game([rating1, rating2], [1, 2])
    next_period = period.generate_next(0.5)
    next_period.players.each { |p| p.update_obj }
    expect(rating1.rating).to be > 1400  # 1403.8
    expect(rating2.rating).to be < 1550  # 1511.9

    # player 1 loses vs. player 2
    rating1 = Rating.new(1400, 30, 0.06)
    rating2 = Rating.new(1550, 100, 0.06)
    period = Glicko2::RatingPeriod.from_objs [rating1, rating2]
    period.game([rating1, rating2], [2, 1])
    next_period = period.generate_next(0.5)
    next_period.players.each { |p| p.update_obj }
    expect(rating1.rating).to be < 1400  # 1398.3
    expect(rating2.rating).to be > 1550  # 1566.1

    # player 1 draws vs. player 2
    rating1 = Rating.new(1400, 30, 0.06)
    rating2 = Rating.new(1550, 100, 0.06)
    period = Glicko2::RatingPeriod.from_objs [rating1, rating2]
    period.game([rating1, rating2], [1, 1])
    next_period = period.generate_next(0.5)
    next_period.players.each { |p| p.update_obj }
    expect(rating1.rating).to be > 1400  # 1401.1
    expect(rating2.rating).to be < 1550  # 1539.0
  end
end
