# logic for the /scoreboard page

class UserScoreboard
  def self.ranked_users(n)
    User.all.sort_by do |user|
      -user.num_repetition_levels_unlocked
    end.take(n)
  end
end
