# Feature Flags Seeds
# Run with: rails db:seed:feature_flags

puts "Creating feature flags..."

# Example feature flags for different features
feature_flags = [
  {
    name: "new_achievements_system",
    enabled: true,
    description: "Enable the new comprehensive achievements system with tiers and progress tracking"
  },
  {
    name: "experimental_puzzle_rating",
    enabled: false,
    description: "Enable experimental puzzle rating system for better difficulty assessment"
  },
  {
    name: "social_features",
    enabled: false,
    description: "Enable social features like following other players and sharing achievements"
  },
  {
    name: "advanced_analytics",
    enabled: true,
    description: "Enable advanced analytics and detailed progress tracking for users"
  },
  {
    name: "beta_game_modes",
    enabled: false,
    description: "Enable access to beta game modes that are still in development"
  },
  {
    name: "enhanced_sound_effects",
    enabled: true,
    description: "Enable enhanced sound effects and audio feedback"
  },
  {
    name: "dark_mode_v2",
    enabled: false,
    description: "Enable the new dark mode theme with improved contrast and colors"
  },
  {
    name: "puzzle_difficulty_ai",
    enabled: false,
    description: "Enable AI-powered puzzle difficulty assessment and adaptive learning"
  },
  {
    name: "adventure_mode",
    enabled: false,
    description: "Enable adventure mode with quest worlds and progression system"
  }
]

feature_flags.each do |flag_attrs|
  flag = FeatureFlag.find_or_initialize_by(name: flag_attrs[:name])
  flag.assign_attributes(flag_attrs)
  
  if flag.save
    puts "✓ Created/updated feature flag: #{flag.name} (#{flag.enabled? ? 'enabled' : 'disabled'})"
  else
    puts "✗ Failed to create feature flag: #{flag.name} - #{flag.errors.full_messages.join(', ')}"
  end
end

puts "Feature flags seeding completed!"
puts "Total feature flags: #{FeatureFlag.count}"
puts "Enabled feature flags: #{FeatureFlag.where(enabled: true).count}"
puts "Disabled feature flags: #{FeatureFlag.where(enabled: false).count}"
