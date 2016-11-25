module MiniboardHelper

  def linked_miniboard(title, fen, goal = "win", depth = nil)
    options = {
      :fen => fen,
      :flip => fen.include?(" b "),
    }
    link = "/position?goal=#{goal}&fen=#{fen}"
    link = "#{link}&depth=#{depth}" if depth
    %(
      <div class="position-board">
        <a href="#{link}">
          #{render :partial => "static/mini_board", :locals => options}
          #{title}
        </a>
      </div>
    ).html_safe
  end

end
