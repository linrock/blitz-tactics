# methods only used when rendering level information

class LevelDisplay

  def initialize(level)
    @level = level
  end

  # /level-1
  def path
    "/#{@level.slug}"
  end

  # Level 1 - Easy street
  def display_name
    return unless @level.present?
    if @level.name
      "#{@level.number} — #{@level.name}"
    else
      @level.number
    end
  end
end
