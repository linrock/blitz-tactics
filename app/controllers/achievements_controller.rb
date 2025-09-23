class AchievementsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_achievements_feature_flag

  def index
    # Get user's solved puzzle count from counter cache
    @solved_puzzles_count = current_user.solved_puzzles_count
    
    # Define puzzle solving achievement tiers
    @puzzle_tiers = [
      { count: 10, title: "👶 First Steps", description: "Solve your first 10 puzzles" },
      { count: 100, title: "🎯 Getting Started", description: "Solve 100 puzzles" },
      { count: 500, title: "🏆 Puzzle Solver", description: "Solve 500 puzzles" },
      { count: 1000, title: "💪 Tactics Master", description: "Solve 1,000 puzzles" },
      { count: 10000, title: "📚 Chess Encyclopedia", description: "Solve 10,000 puzzles" },
      { count: 50000, title: "🌟 Puzzle Legend", description: "Solve 50,000 puzzles" },
      { count: 100000, title: "👑 Chess Grandmaster", description: "Solve 100,000 puzzles" }
    ]
    
    # Find the earliest achievement that has not been unlocked yet
    @next_achievement = @puzzle_tiers.find { |tier| @solved_puzzles_count < tier[:count] }
    
    # Calculate achievement status for each tier
    @puzzle_achievements = @puzzle_tiers.map do |tier|
      is_unlocked = @solved_puzzles_count >= tier[:count]
      is_next_achievement = @next_achievement && tier[:count] == @next_achievement[:count]
      
      # Calculate progress percentage towards this specific tier
      progress_percentage = if is_unlocked
        100
      elsif is_next_achievement
        (@solved_puzzles_count.to_f / tier[:count] * 100).round(1)
      else
        0 # Future achievements don't show progress
      end
      
      {
        tier: tier,
        unlocked: is_unlocked,
        is_next_achievement: is_next_achievement,
        progress_percentage: progress_percentage,
        current_count: @solved_puzzles_count,
        remaining_count: tier[:count] - @solved_puzzles_count
      }
    end
  end

  private

  def check_achievements_feature_flag
    unless FeatureFlag.enabled?(:achievements)
      raise ActionController::RoutingError, 'Not Found'
    end
  end
end
