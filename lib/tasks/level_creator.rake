namespace :level_creator do
  desc "Export complete puzzle pools to text files (all puzzles in each range)"
  task :export_pools, [:output_dir] => :environment do |t, args|
    output_dir = args[:output_dir] || "data/puzzle-pools/"
    
    LevelCreator.export_pools_to_files(output_dir: output_dir)
  end

  desc "Create puzzle set from pre-computed pools with theme variety"
  task :create_set, [:theme_variety] => :environment do |t, args|
    prioritize_theme_variety = args[:theme_variety] != "false"
    
    puzzle_ids = LevelCreator.create_puzzle_set_from_pools(
      prioritize_theme_variety: prioritize_theme_variety
    )
    
    puts "\nPuzzle IDs for puzzle set:"
    puts puzzle_ids.join("\n")
  end

  desc "Analyze pool sizes for all rating ranges"
  task :analyze => :environment do
    puts "Analyzing pool sizes..."
    puts "=" * 50
    
    analysis = LevelCreator.analyze_pool_sizes
    
    analysis.each do |color_to_move, ranges|
      puts "\n#{color_to_move.upcase} to move:"
      ranges.each do |range, count|
        puts "  #{range}: #{count} puzzles"
      end
    end
    
    puts "\n" + "=" * 50
    puts "Analysis complete!"
  end

  desc "Analyze theme distribution across all pools"
  task :analyze_themes => :environment do
    LevelCreator.analyze_theme_distribution_across_pools
  end

  desc "Export example pools (complete pools for all rating ranges)"
  task :export_example => :environment do
    LevelCreator.export_example_pools
  end

  desc "Create example puzzle set from pools (5 from 600-800, 10 from 800-1000, etc.)"
  task :create_example_set, [:theme_variety] => :environment do |t, args|
    prioritize_theme_variety = args[:theme_variety] != "false"
    
    custom_config = LevelCreator.create_custom_config({
      "600-800" => 5,
      "800-1000" => 5,
      "1000-1200" => 10,
      "1200-1400" => 15,
      "1400-1600" => 15,
      "1600-1800" => 15,
      "1800-2000" => 10,
      "2000-2100" => 10,
      "2100-2300" => 5,
      "2300-3200" => 5
    })
    
    puzzle_ids = LevelCreator.create_puzzle_set_from_pools(
      puzzle_counts: custom_config,
      prioritize_theme_variety: prioritize_theme_variety
    )
    
    puts "\nPuzzle IDs for example puzzle set:"
    puts puzzle_ids.join("\n")
  end

  desc "Create a level with random color to move and theme diversity"
  task :create_level => :environment do
    puzzle_ids = LevelCreator.create_level_from_pools
    
    puts "\nPuzzle IDs for level:"
    puts puzzle_ids.join("\n")
  end

  desc "Create a level FAST (no verbose output, optimized for speed)"
  task :create_level_fast => :environment do
    puzzle_ids = LevelCreator.create_level_from_pools_fast
    
    puts puzzle_ids.join("\n")
  end
end
