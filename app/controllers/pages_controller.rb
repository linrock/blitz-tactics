class PagesController < ApplicationController
  before_action :set_user, only: [:home, :world1, :world2, :world3, :world4, :world5, :world6]
  before_action :set_homepage_puzzles, only: [:home, :world1, :world2, :world3, :world4, :world5, :world6]

  def home
    @background_img = "photo-1503180036370-373c16943ae6.jpg"
    @background_overlay = "rgba(0, 0, 0, 0.1)"
    @world_number = 1
    @world_name = "Just getting started"
    
    # Quest mode enabled flag - controlled by feature flag
    @quest_mode_enabled = FeatureFlag.enabled?(:adventure_mode)
    
    # Only load quest data if quest mode is enabled
    if @quest_mode_enabled
      # Load the appropriate QuestWorld based on user's progress or URL parameter
      if params[:world].present?
        @quest_world = QuestWorld.find(params[:world])
      else
        @quest_world = get_next_quest_world_for_user(current_user)
      end
      
      # Only prepare quest data if we have a quest world and it's not completed
      if @quest_world && (!current_user || !@quest_world.completed_by?(current_user))
        @quest_world_levels = @quest_world.quest_world_levels
        # Prepare first puzzle data for each level
        @quest_world_levels_with_puzzles = @quest_world_levels.map do |level|
          first_puzzle = get_first_puzzle_for_level(level)
          level_data = level.attributes
          level_data['first_puzzle'] = first_puzzle
          level_data['success_criteria_description'] = level.success_criteria_description
          level_data['completed'] = current_user ? level.completed_by?(current_user) : false
          level_data
        end
        @all_quest_worlds_complete = false
      else
        # If all worlds completed or no quest world, don't show quest section
        @quest_world = nil
        @quest_world_levels = nil
        @quest_world_levels_with_puzzles = nil
        @all_quest_worlds_complete = current_user && QuestWorld.all.all? { |w| w.completed_by?(current_user) }
      end
    else
      # Quest mode disabled - set all quest variables to nil
      @quest_world = nil
      @quest_world_levels = nil
      @quest_world_levels_with_puzzles = nil
      @all_quest_worlds_complete = false
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

  def puzzle_themes
    # Hardcoded puzzle IDs for each theme (no database queries)
    puzzle_ids = {
      'pin' => '00sHx',
      'skewer' => '00sJ9', 
      'fork' => '00sJb',
      'discoveredAttack' => '00sO1',
      'doubleAttack' => '00sO2',
      'deflection' => '00sO3',
      'decoy' => '00sO4',
      'zwischenzug' => '00sO5',
      'removingTheDefender' => '00sO6',
      'overloadedPiece' => '00sO7',
      'interference' => '00sO8',
      'windmill' => '00sO9',
      'xRayAttack' => '00sPa',
      'backRankMate' => '00sPb',
      'smotheredMate' => '00sPc',
      'battery' => '00sPd',
      'clearanceSacrifice' => '00sPe',
      'attraction' => '00sPf',
      'blocking' => '00sPg',
      'trappedPiece' => '00sPh',
      'desperado' => '00sPi'
    }
    
    # Fetch puzzle objects for the hardcoded IDs
    @theme_examples = {}
    puzzle_ids.each do |theme, puzzle_id|
      puzzle = LichessV2Puzzle.find_by(puzzle_id: puzzle_id)
      @theme_examples[theme] = puzzle if puzzle
    end
  end

  def get_next_quest_world_for_user(user)
    return QuestWorld.first unless user
    
    # Find the first quest world that the user hasn't completed
    QuestWorld.order(:number, :id).find do |world|
      !world.completed_by?(user)
    end # Return nil if all worlds completed
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
    @speedrun_theme = @speedrun_level.theme
    @countdown_level = CountdownLevel.todays_level
    @countdown_puzzle = @countdown_level.first_puzzle
    @haste_puzzle = HastePuzzle.random
    @mate_in_one_puzzle = MateInOnePuzzle.random
    @rook_endgames_puzzle = RookEndgamePuzzle.random
    @openings_puzzle = OpeningPuzzle.random
    @rated_puzzle = RatedPuzzle.order('rating ASC').take(10).shuffle.first
    @scoreboard = Scoreboard.new

    # user-specific
    @infinity_puzzle = @user.next_infinity_puzzle
    @haste_best_score = @user.best_haste_score(Time.zone.today)
    @mate_in_one_best_score = @user.best_mate_in_one_score(Time.zone.today)
    @rook_endgames_best_score = @user.best_rook_endgames_score(Time.zone.today)
    @openings_best_score = @user.best_openings_score(Time.zone.today)
    @three_best_score = @user.best_three_score(Time.zone.today)
    @best_speedrun_time = @user.best_speedrun_time(@speedrun_level)
    @repetition_level = @user.highest_repetition_level_unlocked
    @countdown_level_score = @user.best_countdown_score(@countdown_level)
    @user_rating = @user.user_rating&.rating_string || "Unrated"
  end
end
