class PagesController < ApplicationController

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

  def puzzle_explorer
    @histogram_data = generate_puzzle_histogram
    @theme_data = generate_theme_data
    @total_puzzles = calculate_total_puzzles
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

  def generate_theme_data
    theme_counts = Hash.new(0)
    puzzle_pools_dir = Rails.root.join("data", "puzzle-pools")
    
    # Read all puzzle pool files and count themes
    Dir.glob(puzzle_pools_dir.join("*.txt")).each do |file_path|
      File.readlines(file_path).each do |line|
        next if line.strip.empty?
        
        # Parse line: puzzle_id|rating|themes
        parts = line.strip.split('|')
        next if parts.length < 3
        
        themes = parts[2].split(',')
        themes.each { |theme| theme_counts[theme.strip] += 1 }
      end
    end
    
    # Convert to array format and sort by count (descending)
    theme_counts.map do |theme, count|
      {
        theme: theme,
        formatted_theme: format_theme_name(theme),
        count: count
      }
    end.sort_by { |item| -item[:count] }
  end

  def calculate_total_puzzles
    total = 0
    puzzle_pools_dir = Rails.root.join("data", "puzzle-pools")
    
    # Count total puzzles across all pool files
    Dir.glob(puzzle_pools_dir.join("*.txt")).each do |file_path|
      total += File.readlines(file_path).count { |line| !line.strip.empty? }
    end
    
    total
  end

  def format_theme_name(theme)
    # Convert camelCase to readable format
    theme.gsub(/([A-Z])/, ' \1')
         .gsub(/^./, &:upcase)
         .strip
  end

  def generate_puzzle_histogram
    histogram = {}
    puzzle_pools_dir = Rails.root.join("data", "puzzle-pools")
    
    # Initialize histogram buckets (100-point ranges with special extremes)
    # First bucket: 0-799 (larger range for low ratings)
    histogram["0-799"] = 0
    
    # Middle buckets: 100-point ranges from 800-2099
    (800..2099).step(100) do |start_rating|
      end_rating = start_rating + 99
      bucket_key = "#{start_rating}-#{end_rating}"
      histogram[bucket_key] = 0
    end
    
    # Last bucket: 2100+ (larger range for high ratings)
    histogram["2100+"] = 0
    
    # Read all puzzle pool files
    Dir.glob(puzzle_pools_dir.join("*.txt")).each do |file_path|
      File.readlines(file_path).each do |line|
        next if line.strip.empty?
        
        # Parse line: puzzle_id|rating|themes
        parts = line.strip.split('|')
        next if parts.length < 2
        
        rating = parts[1].to_i
        next if rating < 0 || rating > 4000  # Expanded range to include all ratings
        
        # Find the appropriate bucket
        bucket_key = nil
        
        if rating <= 799
          bucket_key = "0-799"
        elsif rating >= 2100
          bucket_key = "2100+"
        else
          # For 800-2099, use 100-point buckets
          bucket_start = ((rating - 800) / 100) * 100 + 800
          bucket_key = "#{bucket_start}-#{bucket_start + 99}"
        end
        
        histogram[bucket_key] += 1 if histogram.key?(bucket_key)
      end
    end
    
    # Convert to array format for easier JavaScript consumption
    # Sort by the starting rating of each bucket
    histogram.map do |range, count|
      {
        range: range,
        count: count
      }
    end.    sort_by do |item|
      if item[:range] == "0-799"
        0
      elsif item[:range] == "2100+"
        2100
      else
        item[:range].split('-').first.to_i
      end
    end
  end

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

  private

end
