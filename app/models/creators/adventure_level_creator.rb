# AdventureLevelCreator - Generates adventure mode levels with increasing difficulty
#
# Each level consists of multiple puzzle sets with progressively harder puzzles.
# Levels get more complex as the level number increases.
#
# Level Structure:
#   - Levels 1-10: Manually defined for fine-tuned onboarding experience
#   - Levels 11-100: Programmatically generated with scaled rating ranges
#
# Theme Support:
#   Puzzle sets can now specify a theme to use themed puzzle pools:
#   { puzzles: 10, challenge: "solve", description: "Solve 10 fork puzzles", theme: "fork" }
#
#   Themes are loaded from data/themes/{theme}/ directory and must be generated first
#   using ThemedLevelCreator.export_theme_pools_to_files(theme: "fork")
#
# Background Support:
#   Each level can specify a custom background using either:
#   
#   1. Background Image (SVG/PNG file):
#      { description: "Getting started", background_image: "bg-forest.svg", ... }
#      Background images should be placed in app/assets/images/ and referenced by filename.
#   
#   2. CSS Gradient:
#      { description: "Ocean waves", background_gradient: "linear-gradient(90deg, #1CB5E0 0%, #000851 100%)", ... }
#      Use any valid CSS gradient string (linear-gradient, radial-gradient, etc.)
#   
#   If neither is specified, defaults to "bg.svg"
#
# Usage Examples:
#   # Generate a specific level
#   AdventureLevelCreator.generate_level(1)   # Manual level
#   AdventureLevelCreator.generate_level(11)  # Generated level
#   AdventureLevelCreator.generate_level(25)  # Themed level
#
#   # Export all levels to files
#   AdventureLevelCreator.export_all_levels("data/game-modes/adventure/")
#
#   # Analyze available puzzles for each level
#   analysis = AdventureLevelCreator.analyze_level_availability
#
# Rake Tasks:
#   rake adventure:generate_level[1]                    # Generate level 1
#   rake adventure:export_all[data/game-modes/adventure/] # Export all levels
#   rake adventure:analyze                              # Analyze puzzle availability

class AdventureLevelCreator
  # Manually defined levels 1-100 for complete control over difficulty progression
  MANUAL_LEVELS = {
    1 => {
      description: "First steps",
      rating_range: (600..800),
      background_image: "bg.svg",
      puzzle_sets: [
        { puzzles: 2, challenge: "solve" },
        { puzzles: 2, challenge: "speed", time_limit: 10 },
        { puzzles: 3, challenge: "without_mistakes" }
      ]
    },
    2 => {
      description: "Getting started",
      rating_range: (650..850),
      background_gradient: "linear-gradient(90deg, #1CB5E0 0%, #000851 100%)",
      puzzle_sets: [
        { puzzles: 2, challenge: "solve" },
        { puzzles: 2, challenge: "solve" },
        { puzzles: 1, challenge: "checkmate", position_fen: "8/4K3/2q5/8/8/2k5/8/8 b - - 0 1" }
      ]
    },
    3 => {
      description: "Just warming up",
      rating_range: (700..900),
      background_gradient: "linear-gradient(90deg, #3F2B96 0%, #A8C0FF 100%)",
      puzzle_sets: [
        { puzzles: 15, challenge: "solve" },
        { puzzles: 15, challenge: "solve" },
        { puzzles: 15, challenge: "without_mistakes" }
      ]
    },
    4 => {
      description: "Ramping on up",
      rating_range: (750..950),
      background_gradient: "linear-gradient(90deg, #00d2ff 0%, #3a47d5 100%)",
      puzzle_sets: [
        { puzzles: 10, challenge: "solve" },
        { puzzles: 10, challenge: "solve" },
        { puzzles: 10, challenge: "without_mistakes" }
      ]
    },
    5 => {
      description: "Intermediate Challenge",
      rating_range: (800..1000),
      background_gradient: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
      puzzle_sets: [
        { puzzles: 12, challenge: "solve" },
        { puzzles: 10, challenge: "without_mistakes" },
        { puzzles: 10, challenge: "speed", time_limit: 60 }
      ]
    },
    6 => {
      description: "Advanced Tactics",
      rating_range: (850..1050),
      background_gradient: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
      puzzle_sets: [
        { puzzles: 10, challenge: "solve" },
        { puzzles: 10, challenge: "solve" },
        { puzzles: 30, challenge: "move_combo", combo_target: 30 }
      ]
    },
    7 => {
      description: "Master's Path",
      rating_range: (900..1100),
      background_gradient: "linear-gradient(120deg, #f093fb 0%, #f5576c 100%)",
      puzzle_sets: [
        { puzzles: 12, challenge: "solve" },
        { puzzles: 10, challenge: "without_mistakes" },
        { puzzles: 10, challenge: "speed", time_limit: 60 }
      ]
    },
    8 => {
      description: "Expert Territory",
      rating_range: (950..1150),
      background_gradient: "linear-gradient(90deg, #00d2ff 0%, #3a47d5 100%)",
      puzzle_sets: [
        { puzzles: 10, challenge: "solve" },
        { puzzles: 10, challenge: "solve" },
        { puzzles: 10, challenge: "solve" }
      ]
    },
    9 => {
      description: "Elite Challenges",
      rating_range: (1000..1200),
      background_gradient: "linear-gradient(60deg, #4facfe 0%, #00f2fe 100%)",
      puzzle_sets: [
        { puzzles: 12, challenge: "without_mistakes" },
        { puzzles: 10, challenge: "speed", time_limit: 60 },
        { puzzles: 12, challenge: "without_mistakes" }
      ]
    },
    10 => {
      description: "Grandmaster Quest",
      rating_range: (1050..1250),
      background_gradient: "linear-gradient(45deg, #1e3c72 0%, #2a5298 100%)",
      puzzle_sets: [
        { puzzles: 10, challenge: "solve" },
        { puzzles: 20, challenge: "solve" },
        { puzzles: 20, challenge: "solve" }
      ]
    },
    11 => {
      description: "Rising Star",
      rating_range: (1100..1300),
      background_gradient: "linear-gradient(135deg, #fa709a 0%, #fee140 100%)",
      puzzle_sets: [
        { puzzles: 12, challenge: "solve" },
        { puzzles: 10, challenge: "speed", time_limit: 45 },
        { puzzles: 15, challenge: "solve" }
      ]
    },
    12 => {
      description: "Tactical Mastery",
      rating_range: (1150..1350),
      background_gradient: "linear-gradient(90deg, #3F2B96 0%, #A8C0FF 100%)",
      puzzle_sets: [
        { puzzles: 15, challenge: "solve" },
        { puzzles: 12, challenge: "without_mistakes" },
        { puzzles: 10, challenge: "speed", time_limit: 40 }
      ]
    },
    13 => {
      description: "Strategic Depth",
      rating_range: (1200..1400),
      background_gradient: "linear-gradient(120deg, #a8edea 0%, #fed6e3 100%)",
      puzzle_sets: [
        { puzzles: 20, challenge: "solve" },
        { puzzles: 15, challenge: "solve" },
        { puzzles: 12, challenge: "without_mistakes" }
      ]
    },
    14 => {
      description: "Pattern Recognition",
      rating_range: (1250..1450),
      background_gradient: "linear-gradient(135deg, #30cfd0 0%, #330867 100%)",
      puzzle_sets: [
        { puzzles: 18, challenge: "solve" },
        { puzzles: 15, challenge: "speed", time_limit: 60 },
        { puzzles: 20, challenge: "solve" }
      ]
    },
    15 => {
      description: "Endgame Excellence",
      rating_range: (1300..1500),
      background_gradient: "linear-gradient(135deg, #30cfd0 0%, #330867 100%)",
      puzzle_sets: [
        { puzzles: 25, challenge: "solve" },
        { puzzles: 20, challenge: "solve" },
        { puzzles: 15, challenge: "without_mistakes" }
      ]
    },
    16 => {
      description: "Opening Precision",
      rating_range: (1350..1550),
      background_gradient: "linear-gradient(120deg, #89f7fe 0%, #66a6ff 100%)",
      puzzle_sets: [
        { puzzles: 22, challenge: "solve" },
        { puzzles: 18, challenge: "speed", time_limit: 50 },
        { puzzles: 25, challenge: "solve" }
      ]
    },
    17 => {
      description: "Middlegame Mastery",
      rating_range: (1400..1600),
      background_gradient: "linear-gradient(135deg, #667eea 0%, #764ba2 100%)",
      puzzle_sets: [
        { puzzles: 30, challenge: "solve" },
        { puzzles: 25, challenge: "solve" },
        { puzzles: 20, challenge: "without_mistakes" }
      ]
    },
    18 => {
      description: "Calculation Power",
      rating_range: (1450..1650),
      background_gradient: "linear-gradient(90deg, #1CB5E0 0%, #000851 100%)",
      puzzle_sets: [
        { puzzles: 28, challenge: "solve" },
        { puzzles: 22, challenge: "speed", time_limit: 45 },
        { puzzles: 30, challenge: "solve" }
      ]
    },
    19 => {
      description: "Positional Understanding",
      rating_range: (1500..1700),
      background_gradient: "linear-gradient(90deg, #4facfe 0%, #00f2fe 100%)",
      puzzle_sets: [
        { puzzles: 35, challenge: "solve" },
        { puzzles: 30, challenge: "solve" },
        { puzzles: 25, challenge: "without_mistakes" }
      ]
    },
    20 => {
      description: "Advanced Tactics",
      rating_range: (1550..1750),
      background_gradient: "linear-gradient(135deg, #667db6 0%, #0082c8 100%)",
      puzzle_sets: [
        { puzzles: 40, challenge: "solve" },
        { puzzles: 35, challenge: "solve" },
        { puzzles: 30, challenge: "speed", time_limit: 60 }
      ]
    },
    21 => {
      description: "Combinational Vision",
      rating_range: (1600..1800),
      background_gradient: "linear-gradient(135deg, #ff9a56 0%, #ff6a88 100%)",
      puzzle_sets: [
        { puzzles: 45, challenge: "solve" },
        { puzzles: 40, challenge: "solve" },
        { puzzles: 35, challenge: "without_mistakes" }
      ]
    },
    22 => {
      description: "Defensive Mastery",
      rating_range: (1650..1850),
      background_gradient: "linear-gradient(120deg, #e0c3fc 0%, #8ec5fc 100%)",
      puzzle_sets: [
        { puzzles: 50, challenge: "solve" },
        { puzzles: 45, challenge: "speed", time_limit: 75 },
        { puzzles: 40, challenge: "solve" }
      ]
    },
    23 => {
      description: "Attacking Patterns",
      rating_range: (1700..1900),
      background_gradient: "linear-gradient(120deg, #f093fb 0%, #f5576c 100%)",
      puzzle_sets: [
        { puzzles: 55, challenge: "solve" },
        { puzzles: 50, challenge: "solve" },
        { puzzles: 45, challenge: "without_mistakes" }
      ]
    },
    24 => {
      description: "Time Management",
      rating_range: (1750..1950),
      background_gradient: "linear-gradient(135deg, #11998e 0%, #38ef7d 100%)",
      puzzle_sets: [
        { puzzles: 60, challenge: "solve" },
        { puzzles: 55, challenge: "speed", time_limit: 90 },
        { puzzles: 50, challenge: "solve" }
      ]
    },
    25 => {
      description: "Endgame Technique",
      rating_range: (1800..2000),
      background_gradient: "linear-gradient(90deg, #4b6cb7 0%, #182848 100%)",
      puzzle_sets: [
        { puzzles: 65, challenge: "solve" },
        { puzzles: 60, challenge: "solve" },
        { puzzles: 55, challenge: "without_mistakes" }
      ]
    },
    26 => {
      description: "Opening Theory",
      rating_range: (1850..2050),
      background_gradient: "linear-gradient(90deg, #1e3c72 0%, #2a5298 100%)",
      puzzle_sets: [
        { puzzles: 70, challenge: "solve" },
        { puzzles: 65, challenge: "speed", time_limit: 100 },
        { puzzles: 60, challenge: "solve" }
      ]
    },
    27 => {
      description: "Middlegame Strategy",
      rating_range: (1900..2100),
      background_gradient: "linear-gradient(120deg, #84fab0 0%, #8fd3f4 100%)",
      puzzle_sets: [
        { puzzles: 75, challenge: "solve" },
        { puzzles: 70, challenge: "solve" },
        { puzzles: 65, challenge: "without_mistakes" }
      ]
    },
    28 => {
      description: "Tactical Brilliance",
      rating_range: (1950..2150),
      background_gradient: "linear-gradient(135deg, #ff8a00 0%, #da1b60 100%)",
      puzzle_sets: [
        { puzzles: 80, challenge: "solve" },
        { puzzles: 75, challenge: "speed", time_limit: 120 },
        { puzzles: 70, challenge: "solve" }
      ]
    },
    29 => {
      description: "Positional Mastery",
      rating_range: (2000..2200),
      background_gradient: "linear-gradient(90deg, #9796f0 0%, #fbc7d4 100%)",
      puzzle_sets: [
        { puzzles: 85, challenge: "solve" },
        { puzzles: 80, challenge: "solve" },
        { puzzles: 75, challenge: "without_mistakes" }
      ]
    },
    30 => {
      description: "Calculation Excellence",
      rating_range: (2050..2250),
      background_gradient: "linear-gradient(135deg, #d53369 0%, #daae51 100%)",
      puzzle_sets: [
        { puzzles: 90, challenge: "solve" },
        { puzzles: 85, challenge: "speed", time_limit: 150 },
        { puzzles: 80, challenge: "solve" }
      ]
    }
  }.freeze

  # Generate level configuration for levels 31-100 with scaled rating ranges
  def self.generate_level_config
    config = {}
    
    (31..100).each do |level|
      # Calculate rating range progression
      # Level 31: ~2100-2300, Level 100: 2400-3200
      min_rating = 2100 + ((level - 31) * 4.35).round  # Gradual progression
      max_rating = 2300 + ((level - 31) * 13.04).round # Faster max progression
      
      # Ensure we don't exceed the target ranges
      min_rating = [min_rating, 2400].min
      max_rating = [max_rating, 3200].min
      
      # Generate description based on level
      description = generate_level_description(level)
      
      # Generate puzzle sets based on level
      puzzle_sets = generate_puzzle_sets_for_level(level)
      
      config[level] = {
        description: description,
        rating_range: (min_rating..max_rating),
        puzzle_sets: puzzle_sets
      }
    end
    
    config
  end
  
  # Generate level description based on level number (for levels 11-100)
  def self.generate_level_description(level)
    case level
    when 11..25
      "Building Foundations - Level #{level}"
    when 26..40
      "Growing Confidence - Level #{level}"
    when 41..55
      "Intermediate Challenge - Level #{level}"
    when 56..70
      "Advanced Tactics - Level #{level}"
    when 71..85
      "Expert Territory - Level #{level}"
    when 86..95
      "Master's Path - Level #{level}"
    when 96..100
      "Grandmaster Quest - Level #{level}"
    else
      "Adventure Level #{level}"
    end
  end
  
  # Generate puzzle sets based on level complexity (for levels 11-100)
  def self.generate_puzzle_sets_for_level(level)
    case level
    when 25
      # Special themed level: Tactical Mastery
      [
        { puzzles: 10, challenge: "solve", theme: "fork" },
        { puzzles: 10, challenge: "solve", theme: "pin" },
        { puzzles: 10, challenge: "without_mistakes", theme: "skewer" }
      ]
    when 50
      # Special themed level: Checkmate Patterns
      [
        { puzzles: 8, challenge: "solve", theme: "backRankMate" },
        { puzzles: 8, challenge: "solve", theme: "smotheredMate" },
        { puzzles: 8, challenge: "solve", theme: "arabianMate" }
      ]
    when 75
      # Special themed level: Advanced Tactics
      [
        { puzzles: 10, challenge: "solve", theme: "discoveredAttack" },
        { puzzles: 10, challenge: "solve", theme: "deflection" },
        { puzzles: 10, challenge: "without_mistakes", theme: "clearance" }
      ]
    when 11..40
      # Mid-early levels: introduce speed challenges
      [
        { puzzles: 12, challenge: "solve" },
        { puzzles: 10, challenge: "speed", time_limit: 60 },
        { puzzles: 10, challenge: "without_mistakes" }
      ]
    when 41..60
      # Mid levels: more complex challenges
      [
        { puzzles: 15, challenge: "solve" },
        { puzzles: 12, challenge: "speed", time_limit: 60 },
        { puzzles: 10, challenge: "without_mistakes" }
      ]
    when 61..80
      # Advanced levels: introduce move combo challenges
      [
        { puzzles: 15, challenge: "solve" },
        { puzzles: 10, challenge: "speed", time_limit: 60 },
        { puzzles: 20, challenge: "move_combo", combo_target: 20 }
      ]
    when 81..95
      # Expert levels: higher combo targets
      [
        { puzzles: 18, challenge: "solve" },
        { puzzles: 12, challenge: "speed", time_limit: 60 },
        { puzzles: 25, challenge: "move_combo", combo_target: 25 }
      ]
    when 96..100
      # Grandmaster levels: maximum difficulty
      [
        { puzzles: 20, challenge: "solve" },
        { puzzles: 15, challenge: "speed", time_limit: 60 },
        { puzzles: 30, challenge: "move_combo", combo_target: 30 }
      ]
    else
      # Fallback
      [
        { puzzles: 10, challenge: "solve" },
        { puzzles: 10, challenge: "solve" },
        { puzzles: 10, challenge: "without_mistakes" }
      ]
    end
  end

  # Level configuration - combines manual levels 1-30 with generated levels 31-100
  LEVEL_CONFIG = MANUAL_LEVELS.merge(generate_level_config).freeze

  # Challenge type configurations
  CHALLENGE_CONFIGS = {
    'solve' => {
      name: 'Solve',
      description: 'Complete puzzles with mistakes allowed',
      requires_perfect: false,
      time_limit: nil
    },
    'without_mistakes' => {
      name: 'Without Mistakes',
      description: 'Solve puzzles in a row without making any mistakes',
      requires_perfect: true,
      time_limit: nil,
      resets_on_mistake: true
    },
    'speed' => {
      name: 'Speed',
      description: 'Complete puzzles within time limit',
      requires_perfect: false,
      time_limit: 60, # seconds
      resets_on_mistake: false
    },
    'move_combo' => {
      name: 'Move Combo',
      description: 'Reach a move combo without letting it drop',
      requires_perfect: false,
      time_limit: nil,
      resets_on_mistake: false,
      combo_target: 30, # default combo target
      combo_drop_time: nil # default: no timer (combo only drops on mistakes)
      # To enable timer: combo_drop_time: 15 (combo drops after 15 seconds of inactivity)
    },
    'checkmate' => {
      name: 'Checkmate',
      description: 'Win the position by checkmate',
      requires_perfect: true,
      time_limit: nil,
      resets_on_mistake: false,
      position_type: 'checkmate', # indicates this uses position trainer mode
      engine_opponent: true # uses stockfish.js for opponent moves
    }
  }.freeze

  # Get challenge configuration for a specific challenge type
  def self.get_challenge_config(challenge_type)
    CHALLENGE_CONFIGS[challenge_type] || CHALLENGE_CONFIGS['solve']
  end

  # Generate default description for a puzzle set challenge
  def self.generate_default_description(puzzles_count, challenge, time_limit: nil, combo_target: nil, theme: nil)
    challenge_config = get_challenge_config(challenge)
    challenge_name = challenge_config[:name]
    
    # Base puzzle count text
    puzzle_text = puzzles_count == 1 ? "1 puzzle" : "#{puzzles_count} puzzles"
    
    # Theme prefix if specified
    theme_prefix = theme ? "#{theme} " : ""
    
    case challenge
    when 'solve'
      "Solve #{puzzle_text}"
    when 'without_mistakes'
      "Solve #{puzzle_text} without mistakes"
    when 'speed'
      time_text = time_limit ? " in #{time_limit} seconds" : " within time limit"
      "Solve #{puzzle_text}#{time_text}"
    when 'move_combo'
      combo_text = combo_target ? " #{combo_target}" : ""
      "Reach move combo#{combo_text}"
    when 'checkmate'
      "Win by checkmate"
    else
      # Fallback for unknown challenge types
      "Complete #{puzzle_text} in #{challenge_name.downcase} mode"
    end
  end

  # Generate a specific adventure level
  def self.generate_level(level_number)
    config = LEVEL_CONFIG[level_number]
    raise ArgumentError, "Level #{level_number} not defined" unless config

    puts "Generating Adventure Level #{level_number}: #{config[:description]}"
    puts "Rating range: #{config[:rating_range]}"
    puts "Puzzle sets: #{config[:puzzle_sets].length}"

    level_data = {
      level: level_number,
      description: config[:description],
      rating_range: config[:rating_range],
      background_image: config[:background_image], # May be nil if using gradient
      background_gradient: config[:background_gradient], # May be nil if using image
      puzzle_sets: []
    }

    # Generate puzzle sets for this level, alternating between white and black to move
    config[:puzzle_sets].each_with_index do |set_config, set_index|
      # Alternate between white and black to move
      color_to_move = set_index.even? ? 'w' : 'b'

      puzzle_set = generate_puzzle_set(
        level: level_number,
        set_index: set_index + 1,
        puzzles_count: set_config[:puzzles],
        rating_range: config[:rating_range],
        color_to_move: set_config[:color_to_move] || color_to_move,
        challenge: set_config[:challenge],
        challenge_description: set_config[:description],
        theme: set_config[:theme],
        time_limit: set_config[:time_limit],
        position_fen: set_config[:position_fen],
        combo_target: set_config[:combo_target]
      )

      level_data[:puzzle_sets] << puzzle_set
    end

    level_data
  end

  # Generate a single puzzle set for a level using puzzle pool files
  def self.generate_puzzle_set(level:, set_index:, puzzles_count:, rating_range:, color_to_move: 'w', challenge: 'solve', challenge_description: nil, theme: nil, time_limit: nil, position_fen: nil, combo_target: nil)
    # Generate default description if none provided
    challenge_description ||= generate_default_description(puzzles_count, challenge, time_limit: time_limit, combo_target: combo_target, theme: theme)
    
    # For without_mistakes and move_combo challenges, use 2x the number of puzzles to provide variety
    actual_puzzles_count = (challenge == 'without_mistakes' || challenge == 'move_combo') ? puzzles_count * 2 : puzzles_count
    
    theme_text = theme ? " (#{theme} theme)" : ""
    puts "  Generating puzzle set #{set_index} (#{puzzles_count} puzzles required, #{actual_puzzles_count} puzzles in pool, #{color_to_move == 'w' ? 'white' : 'black'} to move, #{challenge_description})#{theme_text}"

    # Handle checkmate challenges differently - they use specific positions, not puzzle pools
    if challenge == 'checkmate'
      challenge_config = get_challenge_config(challenge)
      return {
        set_index: set_index,
        puzzles_count: puzzles_count,
        rating_range: rating_range,
        color_to_move: color_to_move,
        challenge: challenge,
        challenge_description: challenge_description,
        challenge_config: challenge_config,
        position_fen: position_fen,
        puzzles: [] # No puzzle IDs for checkmate challenges
      }
    end

    # Determine which pool file to use based on rating range, color, and theme
    pool_file_info = theme ? find_themed_pool_file_for_rating_range(rating_range, color_to_move, theme) : find_pool_file_for_rating_range(rating_range, color_to_move)
    
    if pool_file_info.nil?
      puts "    ERROR: No pool file found for rating range #{rating_range}"
      return {
        set_index: set_index,
        puzzles_count: 0,
        rating_range: rating_range,
        color_to_move: color_to_move,
        puzzles: []
      }
    end

    # Load puzzles from the pool file
    puzzle_ids = load_puzzles_from_pool_file(pool_file_info[:file_path], actual_puzzles_count)
    
    if puzzle_ids.empty?
      puts "    WARNING: No puzzles found in pool file #{pool_file_info[:filename]}"
      challenge_config = get_challenge_config(challenge)
      return {
        set_index: set_index,
        puzzles_count: 0,
        rating_range: rating_range,
        color_to_move: color_to_move,
        challenge: challenge,
        challenge_description: challenge_description,
        challenge_config: challenge_config,
        puzzles: []
      }
    end

    # Get puzzle data from database using the IDs from pool files
    puzzles = LichessV2Puzzle.where(puzzle_id: puzzle_ids).to_a

    if puzzles.length < puzzles_count
      puts "    WARNING: Only found #{puzzles.length} puzzles in database (requested #{puzzles_count})"
    end

    # Convert to simple list of puzzle IDs
    puzzle_ids = puzzles.map(&:puzzle_id)

    challenge_config = get_challenge_config(challenge)
    # Override time_limit if custom value provided
    challenge_config = challenge_config.merge(time_limit: time_limit) if time_limit
    
    {
      set_index: set_index,
      puzzles_count: puzzles_count, # Required puzzles to solve
      puzzles_in_pool: puzzle_ids.length, # Actual puzzles in the pool
      rating_range: rating_range,
      color_to_move: color_to_move,
      challenge: challenge,
      challenge_description: challenge_description,
      challenge_config: challenge_config,
      theme: theme,
      puzzles: puzzle_ids
    }
  end

  # Find the appropriate pool file for a given rating range and color
  def self.find_pool_file_for_rating_range(rating_range, color_to_move = 'w')
    pools_dir = "data/puzzle-pools/"
    
    # Map rating ranges to pool file numbers
    pool_mapping = {
      (600..800) => 1,
      (800..1000) => 2,
      (1000..1200) => 3,
      (1200..1400) => 4,
      (1400..1600) => 5,
      (1600..1800) => 6,
      (1800..2000) => 7,
      (2000..2100) => 8,
      (2100..2300) => 9,
      (2300..3200) => 10
    }
    
    # Find the best matching pool
    best_pool = nil
    best_overlap = 0
    
    pool_mapping.each do |pool_range, pool_number|
      # Calculate overlap between the requested range and this pool
      overlap_start = [rating_range.min, pool_range.min].max
      overlap_end = [rating_range.max, pool_range.max].min
      overlap = [overlap_end - overlap_start + 1, 0].max
      
      # Choose the pool with the most overlap
      if overlap > best_overlap
        best_overlap = overlap
        best_pool = pool_number
      end
    end
    
    return nil unless best_pool
    
    # Use the specified color to move
    filename = "#{color_to_move}_pool_#{format("%02d", best_pool)}_#{pool_mapping.key(best_pool).min}-#{pool_mapping.key(best_pool).max}.txt"
    file_path = Rails.root.join(pools_dir, filename)
    
    if File.exist?(file_path)
      return {
        filename: filename,
        file_path: file_path,
        color: color_to_move,
        pool_number: best_pool,
        rating_range: pool_mapping.key(best_pool)
      }
    end
    
    nil
  end

  # Find the appropriate themed pool file for a given rating range, color, and theme
  def self.find_themed_pool_file_for_rating_range(rating_range, color_to_move = 'w', theme = nil)
    return nil unless theme
    
    pools_dir = "data/themes/#{theme}/"
    
    # Map rating ranges to pool file numbers (same as regular pools)
    pool_mapping = {
      (600..800) => 1,
      (800..1000) => 2,
      (1000..1200) => 3,
      (1200..1400) => 4,
      (1400..1600) => 5,
      (1600..1800) => 6,
      (1800..2000) => 7,
      (2000..2100) => 8,
      (2100..2300) => 9,
      (2300..3200) => 10
    }
    
    # Find the best matching pool
    best_pool = nil
    best_overlap = 0
    
    pool_mapping.each do |pool_range, pool_number|
      # Calculate overlap between the requested range and this pool
      overlap_start = [rating_range.min, pool_range.min].max
      overlap_end = [rating_range.max, pool_range.max].min
      overlap = [overlap_end - overlap_start + 1, 0].max
      
      # Choose the pool with the most overlap
      if overlap > best_overlap
        best_overlap = overlap
        best_pool = pool_number
      end
    end
    
    return nil unless best_pool
    
    # Use the specified color to move and theme
    filename = "#{color_to_move}_pool_#{format("%02d", best_pool)}_#{pool_mapping.key(best_pool).min}-#{pool_mapping.key(best_pool).max}.txt"
    file_path = Rails.root.join(pools_dir, filename)
    
    if File.exist?(file_path)
      return {
        filename: filename,
        file_path: file_path,
        color: color_to_move,
        pool_number: best_pool,
        rating_range: pool_mapping.key(best_pool),
        theme: theme
      }
    end
    
    nil
  end

  # Load puzzle IDs from a pool file
  def self.load_puzzles_from_pool_file(file_path, count)
    return [] unless File.exist?(file_path)
    
    pool_puzzle_data = File.readlines(file_path).map(&:strip).reject(&:empty?)
    return [] if pool_puzzle_data.empty?
    
    # Randomly sample the requested number of puzzles
    sampled_lines = pool_puzzle_data.sample(count)
    
    # Extract puzzle IDs from the lines
    puzzle_ids = sampled_lines.map do |line|
      parts = line.split("|", 3)
      parts[0] # puzzle_id is the first part
    end.compact
    
    puzzle_ids
  end

  # Expand rating range if not enough puzzles are available
  def self.expand_rating_range(original_range)
    min_rating = [original_range.min - 100, 400].max
    max_rating = [original_range.max + 100, 2500].min
    (min_rating..max_rating)
  end

  # Export a level to a JSON file
  def self.export_level(level_number, output_dir = "data/game-modes/adventure/")
    level_data = generate_level(level_number)
    
    # Ensure output directory exists
    full_output_dir = Rails.root.join(output_dir)
    FileUtils.mkdir_p(full_output_dir)
    
    # Create filename (removed "adventure-" prefix)
    filename = "level-#{level_number.to_s.rjust(2, '0')}.json"
    file_path = File.join(full_output_dir, filename)
    
    # Write level data to file
    File.write(file_path, JSON.pretty_generate(level_data))
    
    puts "✅ Exported Level #{level_number} to #{file_path}"
    
    {
      level: level_number,
      file: filename,
      path: file_path,
      puzzle_sets: level_data[:puzzle_sets].length,
      total_puzzles: level_data[:puzzle_sets].sum { |set| set[:puzzles_count] }
    }
  end

  # Export all levels to files
  def self.export_all_levels(output_dir = "data/game-modes/adventure/")
    puts "Exporting all adventure levels..."
    puts "Output directory: #{output_dir}"
    
    exported_files = []
    
    LEVEL_CONFIG.keys.sort.each do |level_number|
      puts "\n" + "="*50
      file_info = export_level(level_number, output_dir)
      exported_files << file_info
    end
    
    puts "\n" + "="*50
    puts "✅ Export complete!"
    puts "Exported #{exported_files.length} levels to #{Rails.root.join(output_dir)}"
    
    # Summary
    puts "\nSummary:"
    exported_files.each do |file_info|
      puts "  Level #{file_info[:level]}: #{file_info[:puzzle_sets]} sets, #{file_info[:total_puzzles]} puzzles"
    end
    
    exported_files
  end

  # Analyze puzzle availability for each level using pool files
  def self.analyze_level_availability
    puts "Analyzing puzzle availability for adventure levels..."
    
    analysis = {}
    
    LEVEL_CONFIG.each do |level_number, config|
      puts "\nAnalyzing Level #{level_number}: #{config[:description]}"
      puts "Rating range: #{config[:rating_range]}"
      
      # Check both white and black pool files for this level
      white_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'w')
      black_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'b')
      
      if white_pool_info.nil? && black_pool_info.nil?
        puts "  ❌ No pool files found for rating range #{config[:rating_range]}"
        analysis[level_number] = {
          config: config,
          available_puzzles: 0,
          needed_puzzles: 0,
          sufficient: false,
          coverage: 0.0,
          pool_files: []
        }
        next
      end
      
      # Calculate total available puzzles from both colors
      white_count = white_pool_info ? count_puzzles_in_pool_file(white_pool_info[:file_path]) : 0
      black_count = black_pool_info ? count_puzzles_in_pool_file(black_pool_info[:file_path]) : 0
      total_available = white_count + black_count
      
      # Calculate total puzzles needed
      total_needed = config[:puzzle_sets].sum { |set| set[:puzzles] }
      
      # Check if we have enough puzzles
      sufficient = total_available >= total_needed
      
      pool_files = []
      pool_files << white_pool_info[:filename] if white_pool_info
      pool_files << black_pool_info[:filename] if black_pool_info
      
      analysis[level_number] = {
        config: config,
        available_puzzles: total_available,
        needed_puzzles: total_needed,
        sufficient: sufficient,
        coverage: sufficient ? 100.0 : (total_available.to_f / total_needed * 100).round(1),
        pool_files: pool_files
      }
      
      status = sufficient ? "✅ SUFFICIENT" : "⚠️  INSUFFICIENT"
      puts "  Pool files: #{pool_files.join(', ')}"
      puts "  Available: #{total_available} puzzles (W: #{white_count}, B: #{black_count})"
      puts "  Needed: #{total_needed} puzzles"
      puts "  Status: #{status} (#{analysis[level_number][:coverage]}% coverage)"
    end
    
    puts "\n" + "="*50
    puts "Overall Analysis:"
    sufficient_levels = analysis.count { |_, data| data[:sufficient] }
    puts "Levels with sufficient puzzles: #{sufficient_levels}/#{analysis.length}"
    
    analysis
  end

  # Count puzzles in a pool file
  def self.count_puzzles_in_pool_file(file_path)
    return 0 unless File.exist?(file_path)
    
    pool_puzzle_data = File.readlines(file_path).map(&:strip).reject(&:empty?)
    pool_puzzle_data.length
  end

  # Get level configuration for a specific level
  def self.level_config(level_number)
    LEVEL_CONFIG[level_number]
  end

  # Get all available level numbers
  def self.available_levels
    LEVEL_CONFIG.keys.sort
  end

  # Validate that a level can be generated with sufficient puzzles
  def self.can_generate_level?(level_number)
    config = LEVEL_CONFIG[level_number]
    return false unless config

    # Check both white and black pool files
    white_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'w')
    black_pool_info = find_pool_file_for_rating_range(config[:rating_range], 'b')
    
    return false if white_pool_info.nil? && black_pool_info.nil?

    # Count available puzzles from both colors
    white_count = white_pool_info ? count_puzzles_in_pool_file(white_pool_info[:file_path]) : 0
    black_count = black_pool_info ? count_puzzles_in_pool_file(black_pool_info[:file_path]) : 0
    total_available = white_count + black_count

    # Calculate total puzzles needed
    total_needed = config[:puzzle_sets].sum { |set| set[:puzzles] }

    total_available >= total_needed
  end
end
