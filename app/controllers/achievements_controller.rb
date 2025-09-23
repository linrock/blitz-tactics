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
    
    # Calculate achievement status for each tier
    @puzzle_achievements = @puzzle_tiers.map do |tier|
      is_unlocked = @solved_puzzles_count >= tier[:count]
      next_tier = @puzzle_tiers.find { |t| t[:count] > @solved_puzzles_count }
      progress_to_next = next_tier ? (@solved_puzzles_count.to_f / next_tier[:count] * 100).round(1) : 100
      
      {
        tier: tier,
        unlocked: is_unlocked,
        progress: is_unlocked ? 100 : progress_to_next,
        next_tier: next_tier,
        current_count: @solved_puzzles_count
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
