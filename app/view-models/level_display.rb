class LevelDisplay

  def initialize(level)
    @level = level
  end

  def display_name
    return unless @level.present?
    if @level.name
      "#{@level.number} &mdash; #{@level.name}".html_safe
    else
      @level.number
    end
  end
end
