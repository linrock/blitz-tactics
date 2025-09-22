class FeatureFlag < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :enabled, inclusion: { in: [true, false] }

  # Class method to check if a feature is enabled
  def self.enabled?(feature_name)
    find_by(name: feature_name.to_s)&.enabled || false
  end

  # Class method to enable a feature
  def self.enable!(feature_name, description: nil)
    feature = find_or_initialize_by(name: feature_name.to_s)
    feature.enabled = true
    feature.description = description if description
    feature.save!
    feature
  end

  # Class method to disable a feature
  def self.disable!(feature_name)
    feature = find_by(name: feature_name.to_s)
    if feature
      feature.update!(enabled: false)
    end
    feature
  end

  # Class method to toggle a feature
  def self.toggle!(feature_name)
    feature = find_by(name: feature_name.to_s)
    if feature
      feature.update!(enabled: !feature.enabled)
    end
    feature
  end

  # Class method to get all enabled features
  def self.enabled_features
    where(enabled: true).pluck(:name)
  end

  # Class method to get all disabled features
  def self.disabled_features
    where(enabled: false).pluck(:name)
  end

  # Instance method to toggle this feature
  def toggle!
    update!(enabled: !enabled)
  end
end
