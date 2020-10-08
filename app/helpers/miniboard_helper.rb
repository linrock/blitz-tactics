module MiniboardHelper

  # user-created positions on positions page
  def linked_position_miniboard(position)
    options = {
      fen: position.fen,
      flip: position.fen.include?(" b "),
      path: "/positions/#{position.id}",
      title: position.name_or_id,
    }
    render partial: "static/snippets/miniboard_link", locals: options
  end

  # positions and endgames pages
  def linked_miniboard(title, fen, goal = "win", depth = nil)
    link = "/position?goal=#{goal}&fen=#{fen}"
    link = "#{link}&depth=#{depth}" if depth.present?
    options = {
      fen: fen,
      flip: fen.include?(" b "),
      path: link,
      title: title
    }
    render partial: "static/snippets/miniboard_link", locals: options
  end

  # homepage miniboards are rotated if the first move is by white
  def homepage_miniboard_link(path, puzzle)
    options = {
      fen: puzzle.fen,
      initial_move: puzzle.initial_move_uci,
      flip: puzzle.fen.include?(" w "),
      path: path,
    }
    render partial: "static/snippets/miniboard_link", locals: options
  end

  # given a Puzzle model, render a miniboard
  def linked_puzzle_miniboard(puzzle)
    # TODO some puzzles have invalid UCI moves (ex. 66211)
    initial_fen = puzzle.puzzle_data["initial_fen"]
    initial_move_san = puzzle.puzzle_data["initial_move_san"]
    puzzle_id = puzzle.puzzle_id
    render partial: "static/snippets/miniboard_link", locals: {
      fen: initial_fen,
      initial_move_san: initial_move_san,
      flip: initial_fen.include?(" w "),
      path: "/p/#{puzzle_id}"
    }
  end

  # for static routes defined in position_routes.txt
  def linked_miniboard_route(path)
    route = StaticRoutes.new.route_map[path]
    return unless route.present?
    fen = route[:options]["fen"]
    options = {
      fen: fen,
      flip: fen.include?(" b "),
      path: path,
      title: sanitize(route[:title]).split("|")[0].strip
    }
    render partial: "static/snippets/miniboard_link", locals: options
  end
end
