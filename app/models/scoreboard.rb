# stats for homepage + scoreboard page

class Scoreboard

  def initialize
    @recent_time = 24.hours.ago
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

  # past 24 hours

  def recent_scores?
    top_infinity_recent.present? or
    top_haste_scores_recent.present? or
    top_three_scores_recent.present?
  end

  def top_infinity_recent
    @top_infinity_recent ||= group_and_count(
      SolvedInfinityPuzzle.unscoped.where('created_at > ?', @recent_time),
      @n_homepage
    )
  end

  def top_haste_scores_recent
    @top_haste_scores_recent ||= CompletedHasteRound.high_scores(@recent_time)
  end

  def top_three_scores_recent
    @top_three_scores_recent ||= CompletedThreeRound.high_scores(@recent_time)
  end

  def top_repetition_recent
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

  def recent_high_rated
    UserRating
      .where("updated_at > ?", 3.days.ago)
      .order('rating DESC')
      .includes(:user)
      .limit(5)
      .map do |u|
        [
          u.user,
          u.rating.round,
        ]
      end
  end

  def most_rated_puzzles
    UserRating
      .order('rated_puzzle_attempts_count DESC')
      .includes(:user)
      .limit(5)
      .map do |u|
        [
          u.user,
          u.rated_puzzle_attempts_count
        ]
      end
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
