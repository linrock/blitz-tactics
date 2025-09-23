class PagesController < ApplicationController
  before_action :set_user, only: [:home, :world1, :world2, :world3, :world4, :world5, :world6]
  before_action :set_homepage_puzzles, only: [:home, :world1, :world2, :world3, :world4, :world5, :world6]

  def home
    @background_img = "photo-1503180036370-373c16943ae6.jpg"
    @background_overlay = "rgba(0, 0, 0, 0.1)"
    @world_number = 1
    @world_name = "Just getting started"
    
    # Adventure mode enabled flag - controlled by feature flag
    @adventure_mode_enabled = FeatureFlag.enabled?(:adventure_mode)
    
    # Only load adventure data if adventure mode is enabled
    if @adventure_mode_enabled
      # Load adventure levels
      @adventure_levels = load_adventure_levels
      
      if @adventure_levels.any?
        # Determine which level to show (from URL parameter or first level)
        requested_level = params[:level].to_i
        if requested_level > 0
          # Try to load the requested level
          @current_adventure_level = load_adventure_level(requested_level)
          @current_adventure_level_number = requested_level
        else
          # Show the first level by default
          @current_adventure_level = @adventure_levels.first
          @current_adventure_level_number = @current_adventure_level['level']
        end
        
        if @current_adventure_level
          # Check if the current level is completed
          @current_level_completed = current_user ? adventure_level_completed_by_user?(@current_adventure_level_number, current_user) : false
          
          # Prepare puzzle set data for the current level
          @adventure_puzzle_sets = @current_adventure_level['puzzle_sets'].map do |set_data|
            first_puzzle = get_first_puzzle_for_adventure_set(set_data)
            set_data['first_puzzle'] = first_puzzle
            set_data['completed'] = current_user ? set_completed_by_user?(@current_adventure_level_number, set_data['set_index'], current_user) : false
            set_data
          end
          
          # Calculate progress for the current level
          @completed_sets_count = @adventure_puzzle_sets.count { |set| set['completed'] }
          @total_sets_count = @adventure_puzzle_sets.length
          
          # Check if there's a next level available
          @next_level_number = @current_adventure_level_number + 1
          @next_level_data = load_adventure_level(@next_level_number)
        else
          # Requested level not found, show first level
          @current_adventure_level = @adventure_levels.first
          @current_adventure_level_number = @current_adventure_level['level']
          @current_level_completed = current_user ? adventure_level_completed_by_user?(@current_adventure_level_number, current_user) : false
          @adventure_puzzle_sets = @current_adventure_level['puzzle_sets'].map do |set_data|
            first_puzzle = get_first_puzzle_for_adventure_set(set_data)
            set_data['first_puzzle'] = first_puzzle
            set_data['completed'] = current_user ? set_completed_by_user?(@current_adventure_level_number, set_data['set_index'], current_user) : false
            set_data
          end
          
          # Calculate progress for the current level
          @completed_sets_count = @adventure_puzzle_sets.count { |set| set['completed'] }
          @total_sets_count = @adventure_puzzle_sets.length
          
          # Check if there's a next level available
          @next_level_number = @current_adventure_level_number + 1
          @next_level_data = load_adventure_level(@next_level_number)
        end
        
        @all_adventure_levels_complete = false
      else
        # No adventure levels available
        @current_adventure_level = nil
        @current_adventure_level_number = nil
        @current_level_completed = false
        @adventure_puzzle_sets = []
        @all_adventure_levels_complete = false
      end
    else
      # Adventure mode disabled - set all adventure variables to nil
      @current_adventure_level = nil
      @current_adventure_level_number = nil
      @current_level_completed = false
      @adventure_puzzle_sets = []
      @all_adventure_levels_complete = false
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

  def load_adventure_levels
    adventure_dir = Rails.root.join("data", "game-modes", "adventure")
    return [] unless Dir.exist?(adventure_dir)
    
    levels = []
    
    # Find all level JSON files
    Dir.glob(adventure_dir.join("level-*.json")).sort.each do |file_path|
      begin
        level_data = JSON.parse(File.read(file_path))
        levels << level_data
      rescue JSON::ParserError => e
        Rails.logger.error "Error parsing adventure level file #{file_path}: #{e.message}"
      end
    end
    
    levels
  end

  def adventure_level_completed_by_user?(level_number, user)
    return false unless user
    
    # Check if all puzzle sets in the level are completed
    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}
    
    # Load the level data to check how many sets it has
    level_data = load_adventure_level(level_number)
    return false unless level_data
    
    # Check if all puzzle sets are completed
    level_data['puzzle_sets'].all? do |set|
      level_completions[set['set_index'].to_s] == true
    end
  end

  def get_first_puzzle_for_adventure_level(level_data)
    return nil unless level_data['puzzle_sets'].present? && level_data['puzzle_sets'].is_a?(Array)

    first_set = level_data['puzzle_sets'].first
    return nil unless first_set['puzzles'].present? && first_set['puzzles'].is_a?(Array)

    first_puzzle_id = first_set['puzzles'].first
    return nil if first_puzzle_id.blank?

    # Try to find the puzzle by puzzle_id
    puzzle = LichessV2Puzzle.find_by(puzzle_id: first_puzzle_id.to_s)
    return nil unless puzzle

    {
      puzzle_id: puzzle.puzzle_id,
      fen: puzzle.initial_fen,
      initial_fen: puzzle.initial_fen,
      initial_move: puzzle.moves_uci[0],
      rating: puzzle.rating,
      themes: puzzle.themes
    }
  end

  def get_first_puzzle_for_adventure_set(set_data)
    return nil unless set_data['puzzles'].present? && set_data['puzzles'].is_a?(Array)

    first_puzzle_id = set_data['puzzles'].first
    return nil if first_puzzle_id.blank?

    # Try to find the puzzle by puzzle_id
    puzzle = LichessV2Puzzle.find_by(puzzle_id: first_puzzle_id.to_s)
    return nil unless puzzle

    {
      puzzle_id: puzzle.puzzle_id,
      fen: puzzle.initial_fen,
      initial_fen: puzzle.initial_fen,
      initial_move: puzzle.moves_uci[0],
      rating: puzzle.rating,
      themes: puzzle.themes
    }
  end

  def set_completed_by_user?(level_number, set_index, user)
    return false unless user
    
    # Use user profile to track adventure completions
    user_profile = user.profile || {}
    adventure_completions = user_profile['adventure_completions'] || {}
    level_completions = adventure_completions[level_number.to_s] || {}
    
    level_completions[set_index.to_s] == true
  end

  def load_adventure_level(level_number)
    level_file = Rails.root.join("data", "game-modes", "adventure", "level-#{level_number.to_s.rjust(2, '0')}.json")
    
    return nil unless File.exist?(level_file)
    
    begin
      JSON.parse(File.read(level_file))
    rescue JSON::ParserError => e
      Rails.logger.error "Error parsing adventure level #{level_number}: #{e.message}"
      nil
    end
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
