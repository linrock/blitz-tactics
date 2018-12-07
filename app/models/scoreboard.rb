# stats for homepage + scoreboard page

class Scoreboard

  def initialize
    @recent_time = 7.days.ago
    @n_homepage = 5
    @n_scoreboard = 10
  end

  def fastest_speedruns(speedrun_level)
    speedrun_level.fastest_speedruns
  end

  # most infinity puzzles solved in the past 7 days
  def top_infinity_recent
    @top_infinity_recent ||= group_and_count(
      SolvedInfinityPuzzle.unscoped.where('created_at > ?', @recent_time),
      @n_homepage
    )
  end

  # most repetition levels solved in the past 7 days
  def top_repetition_recent
    @top_repetition_recent ||= group_and_count(
      CompletedRepetitionLevel.unscoped.where('created_at > ?', @recent_time),
      @n_homepage
    )
  end

  def top_speedruns
    group_and_count(CompletedSpeedrun.unscoped, @n_scoreboard)
  end

  def top_infinity
    group_and_count(SolvedInfinityPuzzle.unscoped, @n_scoreboard)
  end

  def top_repetition
    group_and_count(CompletedRepetitionLevel.unscoped, @n_scoreboard)
  end

  def hall_of_fame
    @hall_of_fame ||= User.all_repetition_levels_unlocked
  end

  private

  def group_and_count(scope, n)
    scope
      .group(:user_id).count
      .sort_by {|_,v| -v }.take(n)
      .map do |user_id, count|
        [
          User.find_by(id: user_id),
          count
        ]
      end
  end
end
