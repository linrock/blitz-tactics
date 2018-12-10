# stats for homepage + scoreboard page

class Scoreboard

  def initialize
    @recent_time = 7.days.ago
    @n_homepage = 5
    @n_scoreboard = 10
  end

  # homepage scoreboard

  def fastest_speedruns(speedrun_level)
    return unless speedrun_level.present?
    speedrun_level.completed_speedruns.group(:user_id).minimum(:elapsed_time_ms)
      .sort_by(&:last).take(@n_homepage)
      .map do |user_id, elapsed_time_ms|
        [
          User.find_by(id: user_id),
          sprintf("%0.1fs" % (elapsed_time_ms.to_f / 1000))
        ]
      end
  end

  def countdown_high_scores(countdown_level)
    return unless countdown_level.present?
    CompletedCountdownLevel.where(countdown_level_id: countdown_level.id)
      .group(:user_id).maximum(:score)
      .sort_by {|_,v| -v }.take(@n_homepage)
      .map do |user_id, score|
        [
          User.find_by(id: user_id),
          score
        ]
      end
  end

  def top_infinity_recent # most infinity puzzles solved in the past 7 days
    @top_infinity_recent ||= group_and_count(
      SolvedInfinityPuzzle.unscoped.where('created_at > ?', @recent_time),
      @n_homepage
    )
  end

  def top_repetition_recent # most repetition levels solved in the past 7 days
    @top_repetition_recent ||= group_and_count(
      CompletedRepetitionLevel.unscoped.where('created_at > ?', @recent_time),
      @n_homepage
    )
  end

  # scoreboard standalone page

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
    @hall_of_fame ||= User.where("jsonb_array_length(profile -> 'levels_unlocked') = 65")
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
