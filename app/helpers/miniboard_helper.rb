module MiniboardHelper

  def render_miniboard_link(options)
    render partial: "static/snippets/miniboard_link", locals: options
  end

  # user-created positions on positions page
  def linked_position_miniboard(position)
    render_miniboard_link({
      fen: position.fen,
      flip: position.fen.include?(" b "),
      path: "/positions/#{position.id}",
      title: position.name_or_id,
    })
  end

  # positions and endgames pages
  def linked_miniboard(title, fen, goal = "win", depth = nil)
    link = "/position?goal=#{goal}&fen=#{fen}"
    link = "#{link}&depth=#{depth}" if depth.present?
    render_miniboard_link({
      fen: fen,
      flip: fen.include?(" b "),
      path: link,
      title: title
    })
  end

  # homepage miniboards are rotated if the first move is by white
  def homepage_miniboard_link(path, puzzle)
    render_miniboard_link({
      fen: puzzle.fen,
      initial_move_san: puzzle.initial_move_san,
      flip: puzzle.fen.include?(" w "),
      path: path,
    })
  end

  # given a Puzzle model, render a miniboard
  def linked_puzzle_miniboard(puzzle)
    # TODO some puzzles have invalid UCI moves (ex. 66211)
    initial_fen = puzzle.puzzle_data["initial_fen"]
    initial_move_san = puzzle.puzzle_data["initial_move_san"]
    puzzle_id = puzzle.puzzle_id
    render_miniboard_link({
      fen: initial_fen,
      initial_move_san: initial_move_san,
      flip: initial_fen.include?(" w "),
      path: "/p/#{puzzle_id}"
    })
  end

  # for static routes defined in position_routes.txt
  def linked_miniboard_route(path)
    route = StaticRoutes.new.route_map[path]
    return unless route.present?
    fen = route[:options]["fen"]
    render_miniboard_link({
      fen: fen,
      flip: fen.include?(" b "),
      path: path,
      title: sanitize(route[:title]).split("|")[0].strip
    })
  end
end
