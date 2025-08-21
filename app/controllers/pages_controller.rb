class PagesController < ApplicationController
  before_action :set_user, only: [:home, :world1, :world2, :world3, :world4, :world5, :world6]
  before_action :set_homepage_puzzles, only: [:home, :world1, :world2, :world3, :world4, :world5, :world6]

  def home
    @background_img = "photo-1503180036370-373c16943ae6.jpg"
    @background_overlay = "rgba(0, 0, 0, 0.1)"
    @world_number = 1
    @world_name = "Just getting started"
    
    # Load the first QuestWorld and its levels
    @quest_world = QuestWorld.first
    if @quest_world
      @quest_world_levels = @quest_world.quest_world_levels
      # Prepare first puzzle data for each level
      @quest_world_levels_with_puzzles = @quest_world_levels.map do |level|
        first_puzzle = get_first_puzzle_for_level(level)
        level_data = level.attributes
        level_data['first_puzzle'] = first_puzzle
        level_data['success_criteria_description'] = level.success_criteria_description
        level_data
      end
    end
    
    render "/home"
  end

  def world1
    @background_img = "photo-1503180036370-373c16943ae6.jpg"
    @background_overlay = "rgba(0, 0, 0, 0.1)"
    @world_number = 1
    @world_name = "Just getting started"
    render "/home"
  end

  def world2
    @background_img = "dusty-sky.jpg"
    @background_overlay = "rgba(0, 0, 0, 0.3)"
    @world_number = 2
    @world_name = "Getting warmed up"
    render "/home"
  end

  def world3
    @background_img = "photo-1461511669078-d46bf351cd6e.jpg"
    @background_overlay = "rgba(0, 0, 0, 0)"
    @world_number = 3
    @world_name = "Triple trouble"
    render "/home"
  end

  def world4
    @background_img = "photo-1619367300934-373d9adf7dfb-1.avif"
    @background_overlay = "radial-gradient(circle, rgba(0, 0, 0, 0) 60%, rgba(0, 0, 0, 0.5) 100%)"
    @world_number = 4
    @world_name = "Royally forked"
    render "/home"
  end

  def world5
    # @background_img = "photo-1508583732154-e9ff899f8534.avif"
    @background_img = "photo-1499988921418-b7df40ff03f9.avif"
    @background_overlay = "rgba(0, 0, 0, 0.1)"
    @world_number = 5
    @world_name = "Still warming up"
    render "/home"
  end

  def world6
    @background_img = "photo-1619367300934-373d9adf7dfb-1.avif"
    @background_overlay = "rgba(0, 0, 0, 0.2)"
    @world_number = 6
    @world_name = "Hexadecimal"
    render "/home"
  end

  def puzzle_player
    @puzzles = HastePuzzle.random_level(100).as_json(lichess_puzzle_id: true)
  end

  def positions
  end

  def position
    if params[:id].present?
      @position = Position.find(params[:id])
    else
      @position = Position.new(fen: params[:fen], goal: params[:goal])
    end
  end

  def defined_position
    pathname = request.path.gsub(/\/\z/, '')
    @route = StaticRoutes.new.route_map[pathname]
  end

  def scoreboard
    @scoreboard = Scoreboard.new
    @recent_days = {
      "2 days ago" => :two_days_ago_level,
      "Yesterday"  => :yesterdays_level,
      "Today"      => :todays_level
    }
  end

  def pawn_endgames
  end

  def about
  end

  private

  def get_first_puzzle_for_level(level)
    return nil unless level.puzzle_ids.present? && level.puzzle_ids.is_a?(Array)

    first_puzzle_id = level.puzzle_ids.first
    return nil if first_puzzle_id.blank?

    # Try to find the puzzle by puzzle_id
    puzzle = LichessV2Puzzle.find_by(puzzle_id: first_puzzle_id.to_s)
    return nil unless puzzle

    {
      puzzle_id: puzzle.puzzle_id,
      fen: puzzle.initial_fen, # Use initial FEN like quest level edit page
      initial_fen: puzzle.initial_fen,
      initial_move: puzzle.moves_uci[0], # Setup move (first move in sequence) like quest level edit page
      rating: puzzle.rating,
      themes: puzzle.themes
    }
  end

  def set_homepage_puzzles
    @hours_until_tomorrow = 24 - DateTime.now.hour
    @speedrun_level = SpeedrunLevel.todays_level
    @speedrun_puzzle = @speedrun_level.first_puzzle
    @countdown_level = CountdownLevel.todays_level
    @countdown_puzzle = @countdown_level.first_puzzle
    @haste_puzzle = HastePuzzle.random
    @rated_puzzle = RatedPuzzle.order('rating ASC').take(10).shuffle.first
    @scoreboard = Scoreboard.new

    # user-specific
    @infinity_puzzle = @user.next_infinity_puzzle
    @haste_best_score = @user.best_haste_score(Date.today)
    @three_best_score = @user.best_three_score(Date.today)
    @best_speedrun_time = @user.best_speedrun_time(@speedrun_level)
    @repetition_level = @user.highest_repetition_level_unlocked
    @countdown_level_score = @user.best_countdown_score(@countdown_level)
    @user_rating = @user.user_rating&.rating_string || "Unrated"
  end
end
