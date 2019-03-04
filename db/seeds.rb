# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

w_puzzle_data = {
  "id" => 1435,
  "fen" => "1r4nk/5p1p/pp1q1PB1/2pP1rP1/P1P1p3/2N1Q3/1P5R/R5K1 b - - 0 30",
  "lines" => {"h2h7"=>{"h8h7"=>{"e3h3"=>{"g8h6"=>{"h3h6"=>{"h7g8"=>{"h6g7"=>"win"}}}}}}},
  "initialMove" => {"san"=>"fxg6", "uci"=>"f7g6"}
}

b_puzzle_data = {
  "id" => 61674,
  "fen" => "8/1p4p1/p1kp1b1p/5R2/1PP5/P1Nn2P1/6K1/8 w - - 5 39",
  "lines"=>{"d3e1"=>{"g2f2"=>{"e1f3"=>{"b4b5"=>"win"}}}},
  "initialMove"=>{"san"=>"Rf3", "uci"=>"f5f3"}
}

level = CountdownLevel.find_or_create_by!(name: CountdownLevel.today.to_s)
level.countdown_puzzles.create(data: w_puzzle_data)

level = SpeedrunLevel.find_or_create_by!(name: SpeedrunLevel.today.to_s)
level.speedrun_puzzles.create(data: b_puzzle_data)

HastePuzzle.create(data: w_puzzle_data, difficulty: 0, color: 'w')
HastePuzzle.create(data: b_puzzle_data, difficulty: 0, color: 'b')

level = RepetitionLevel.find_or_create_by!(number: 1)
level.repetition_puzzles.create(data: w_puzzle_data)

InfinityLevel::DIFFICULTIES.each do |difficulty|
  level = InfinityLevel.find_or_create_by!(difficulty: difficulty)
  level.infinity_puzzles.create(data: w_puzzle_data)
end

RatedPuzzle.create(
  data: w_puzzle_data,
  color: 'w',
  initial_rating: 1500,
  initial_rating_deviation: 350,
  initial_rating_volatility: 0.06,
  rating: 1500,
  rating_deviation: 350,
  rating_volatility: 0.06,
) rescue nil
