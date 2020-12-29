module ChessJS
  extend self

  def fen_after_move_san(fen, move_san)
    context.exec("
      const chess = new Chess('#{fen}');
      chess.move('#{move_san}');
      return chess.fen();
    ")
  end

  def get_move_sequence_cjs(initial_fen, move_sequence_uci)
    moves = []
    fen = initial_fen
    move_sequence_uci.each do |move_uci|
      cjs_move = get_move_from_move_uci(fen, move_uci)
      moves << cjs_move
      fen = fen_after_move_uci(fen, move_uci)
    end
    if moves.length != move_sequence_uci.length || moves.compact.length != moves.length
      throw "Invalid chess.js move sequence: #{moves}"
    end
    moves
  end

  def get_move_from_move_uci(fen, move_uci)
    from = move_uci[0..1]
    to = move_uci[2..3]
    promotion = nil
    move = "{ from: '#{from}', to: '#{to}' }"
    if move_uci.length == 5
      move = "{ from: '#{from}', to: '#{to}', promotion: '#{move_uci[4]}' }"
    end
    context.exec("
      const chess = new Chess('#{fen}');
      return chess.move(#{move});
    ")
  end

  def fen_after_move_uci(fen, move_uci)
    from = move_uci[0..1]
    to = move_uci[2..3]
    promotion = nil
    move = "{ from: '#{from}', to: '#{to}' }"
    if move_uci.length == 5
      move = "{ from: '#{from}', to: '#{to}', promotion: '#{move_uci[4]}' }"
    end
    context.exec("
      const chess = new Chess('#{fen}');
      chess.move(#{move});
      return chess.fen();
    ")
  end

  def context
    @@context ||= ExecJS.compile(open(Rails.root.join("node_modules/chess.js/chess.js")).read)
  end
end
