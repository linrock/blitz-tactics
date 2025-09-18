namespace :themed_levels do
  desc "Export puzzle pools for a specific theme"
  task :export_pools, [:theme] => :environment do |t, args|
    theme = args[:theme]
    
    if theme.blank?
      puts "Usage: rake themed_levels:export_pools[theme]"
      puts "Example: rake themed_levels:export_pools[opening]"
      puts "\nAvailable themes:"
      ThemedLevelCreator.list_themes
      exit 1
    end
    
    begin
      ThemedLevelCreator.export_theme_pools_to_files(theme: theme)
    rescue ArgumentError => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Export puzzle pools for multiple themes"
  task :export_multiple_themes, [:themes] => :environment do |t, args|
    themes = args[:themes]&.split(',')&.map(&:strip)
    
    if themes.blank?
      puts "Usage: rake themed_levels:export_multiple_themes[theme1,theme2,theme3]"
      puts "Example: rake themed_levels:export_multiple_themes[opening,fork,pin]"
      puts "\nAvailable themes:"
      ThemedLevelCreator.list_themes
      exit 1
    end
    
    themes.each do |theme|
      puts "\n" + "="*60
      puts "Exporting #{theme} theme pools..."
      puts "="*60
      
      begin
        ThemedLevelCreator.export_theme_pools_to_files(theme: theme)
      rescue ArgumentError => e
        puts "Error with theme '#{theme}': #{e.message}"
        next
      end
    end
    
    puts "\n" + "="*60
    puts "All theme exports complete!"
    puts "="*60
  end

  desc "Analyze pool sizes for a specific theme"
  task :analyze_pools, [:theme] => :environment do |t, args|
    theme = args[:theme]
    
    if theme.blank?
      puts "Usage: rake themed_levels:analyze_pools[theme]"
      puts "Example: rake themed_levels:analyze_pools[opening]"
      puts "\nAvailable themes:"
      ThemedLevelCreator.list_themes
      exit 1
    end
    
    begin
      analysis = ThemedLevelCreator.analyze_theme_pool_sizes(theme: theme)
      
      puts "\n#{theme.capitalize} Theme Pool Analysis:"
      puts "="*50
      
      %w[w b].each do |color_to_move|
        puts "\n#{color_to_move.upcase} to move:"
        analysis[color_to_move].each do |rating_range, count|
          puts "  #{rating_range}: #{count} puzzles"
        end
        total = analysis[color_to_move].values.sum
        puts "  Total: #{total} puzzles"
      end
      
    rescue ArgumentError => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Get statistics for a specific theme"
  task :theme_stats, [:theme] => :environment do |t, args|
    theme = args[:theme]
    
    if theme.blank?
      puts "Usage: rake themed_levels:theme_stats[theme]"
      puts "Example: rake themed_levels:theme_stats[opening]"
      puts "\nAvailable themes:"
      ThemedLevelCreator.list_themes
      exit 1
    end
    
    begin
      ThemedLevelCreator.theme_stats(theme: theme)
    rescue ArgumentError => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "List all available themes"
  task :list_themes => :environment do
    ThemedLevelCreator.list_themes
  end

  desc "Create a puzzle set from theme pools (for testing)"
  task :create_puzzle_set, [:theme] => :environment do |t, args|
    theme = args[:theme]
    
    if theme.blank?
      puts "Usage: rake themed_levels:create_puzzle_set[theme]"
      puts "Example: rake themed_levels:create_puzzle_set[opening]"
      puts "\nAvailable themes:"
      ThemedLevelCreator.list_themes
      exit 1
    end
    
    begin
      puzzle_data = ThemedLevelCreator.create_puzzle_set_from_theme_pools(theme: theme)
      puts "\nCreated puzzle set with #{puzzle_data.length} puzzles"
      
      # Show first few puzzles as examples
      puts "\nFirst 3 puzzles:"
      puzzle_data.first(3).each_with_index do |puzzle, index|
        puts "  #{index + 1}. #{puzzle['id']} (Rating: #{puzzle['rating']})"
      end
      
    rescue ArgumentError => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Export all common themes (opening, endgame, fork, pin, sacrifice)"
  task :export_common_themes => :environment do
    common_themes = %w[opening endgame fork pin sacrifice]
    
    puts "Exporting common chess themes: #{common_themes.join(', ')}"
    puts "="*60
    
    common_themes.each do |theme|
      puts "\n" + "-"*40
      puts "Exporting #{theme} theme..."
      puts "-"*40
      
      begin
        ThemedLevelCreator.export_theme_pools_to_files(theme: theme)
      rescue ArgumentError => e
        puts "Error with theme '#{theme}': #{e.message}"
        next
      end
    end
    
    puts "\n" + "="*60
    puts "Common themes export complete!"
    puts "="*60
  end
end
