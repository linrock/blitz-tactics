# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

puzzle_data = {
  "id" => 1435,
  "fen" => "1r4nk/5p1p/pp1q1PB1/2pP1rP1/P1P1p3/2N1Q3/1P5R/R5K1 b - - 0 30",
  "lines" => {"h2h7"=>{"h8h7"=>{"e3h3"=>{"g8h6"=>{"h3h6"=>{"h7g8"=>{"h6g7"=>"win"}}}}}}},
  "initialMove" => {"san"=>"fxg6", "uci"=>"f7g6"}
}

level = CountdownLevel.find_or_create_by!(name: CountdownLevel.today.to_s)
level.countdown_puzzles.create(data: puzzle_data)

level = SpeedrunLevel.find_or_create_by!(name: SpeedrunLevel.today.to_s)
level.speedrun_puzzles.create(data: puzzle_data)

HastePuzzle.create(data: puzzle_data, difficulty: 0, color: 'w')

level = RepetitionLevel.find_or_create_by!(number: 1)
level.repetition_puzzles.create(data: puzzle_data)

InfinityLevel::DIFFICULTIES.each do |difficulty|
  level = InfinityLevel.find_or_create_by!(difficulty: difficulty)
  level.infinity_puzzles.create(data: puzzle_data)
end

RatedPuzzle.create(
  data: puzzle_data,
  color: 'w',
  initial_rating: 1500,
  initial_rating_deviation: 350,
  initial_rating_volatility: 0.06,
  rating: 1500,
  rating_deviation: 350,
  rating_volatility: 0.06,
)
