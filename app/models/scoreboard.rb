# homepage scoreboard

class Scoreboard

  def initialize
    @time = 7.days.ago
    @n = 5
  end

  def fastest_speedruns(speedrun_level)
    speedrun_level.fastest_speedruns
  end

  # most infinity puzzles solved in the past 7 days
  def top_infinity
    @top_infinity ||= SolvedInfinityPuzzle.unscoped
      .where('created_at > ?', @time)
      .group(:user_id).count
      .sort_by {|_,v| -v }.take(@n)
      .map {|user_id, count| [User.find_by(id: user_id), count] }
  end

  # most repetition levels solved in the past 7 days
  def top_repetition
    @top_repetition ||= CompletedRepetitionLevel.unscoped
      .where('created_at > ?', @time)
      .group(:user_id).count
      .sort_by {|_,v| -v }.take(@n)
      .map {|user_id, count| [User.find_by(id: user_id), count] }
  end
end
