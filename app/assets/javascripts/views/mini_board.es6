{

  // TODO copy/paste from models/puzzles
  //
  let uciToMove = (uci) => {
    let m = {
      from: uci.slice(0,2),
      to: uci.slice(2,4)
    }
    if (uci.length === 5) {
      m.promotion = uci[4]
    }
    return m
  }

  // For handling the DOM elements of the pieces on the board
  //
  class Pieces {

    constructor(board) {
      this.board = board
      this.$buffer = $("<div>").addClass("piece-buffer")
    }

    reset() {
      this.board.$(".piece").appendTo(this.$buffer)
    }
    
    $getPiece(piece) {
      let className = piece.color + piece.type
      let $piece = this.$buffer.find("." + className).first()
      if ($piece.length) {
        return $piece
      }
      return $("<img>").
        attr("src", `/assets/pieces/${className}.png`).
        addClass(`piece ${className} ${piece.color}`)
    }

  }


  class MiniChessboard extends Backbone.View {

    initialize(options = {}) {
      this.pieces = new Pieces(this)
      if (options.fen) {
        let fen = options.fen
        if (options.initialMove) {
          let c = new Chess(fen)
          let move = c.move(uciToMove(options.initialMove))
          this.highlightSquare(move.from, "#fffcdd")
          this.highlightSquare(move.to, "#fff79b")
          fen = c.fen()
        }
        this.render(fen)
      }
    }

    render(fen) {
      if (fen.split(" ").length === 4) {
        fen += " 0 1"
      }
      this.renderFen(fen)
    }

    renderFen(fen) {
      let columns = ['a','b','c','d','e','f','g','h']
      let position = new Chess(fen)
      this.pieces.reset()
      for (let row = 8; row > 0; row--) {
        for (let j = 0; j < 8; j++) {
          let id = columns[j] + row
          let piece = position.get(id)
          if (piece) {
            this.pieces.$getPiece(piece).appendTo(this.$getSquare(id))
          }
        }
      }
    }

    highlightSquare(id, color) {
      this.$getSquare(id).css({ background: color })
    }

    $getSquare(id) {
      return this.$(`.${id}`)
    }

  }


  Views.MiniChessboard = MiniChessboard

}
