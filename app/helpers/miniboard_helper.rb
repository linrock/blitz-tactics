module MiniboardHelper

  def linked_miniboard(title, fen)
    options = {
      :fen => fen,
      :flip => fen.include?(" b ")
    }
    %(
      <div class="position-board">
        <a href="/position?goal=win&fen=#{fen}">
          #{render :partial => "static/mini_board", :locals => options}
          #{title}
        </a>
      </div>
    ).html_safe
  end

end
