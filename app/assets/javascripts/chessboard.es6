// Basic chessboard that just renders positions

{

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
        addClass(`invisible piece ${className}`)
    }

  }


  // Drag and drop pieces to move them
  //
  class DragAndDrop {

    constructor(board) {
      this.board = board
      this.initialized = false
    }

    init() {
      if (this.initialized) {
        return
      }
      this.initDraggable()
      this.initDroppable()
      this.initialized = true
    }

    initDraggable() {
      this.board.$(".piece").draggable({
        stack: ".piece",
        distance: 5,
        revert: true,
        revertDuration: 0
      })
    }

    initDroppable() {
      this.board.$(".square").droppable({
        accept: ".piece",
        tolerance: "pointer",
        drop: (event, ui) => {
          let move = {
            from: $(ui.draggable).parents(".square").data("square"),
            to: $(event.target).data("square"),
            promotion: 'q'
          }
          let c = new Chess(this.board.fen)
          let m = c.move(move)
          if (m) {
            d.trigger("move:try", m)
          }
        }
      })
    }

  }


  class Chessboard extends Backbone.View {

    get el() {
      return ".chessboard"
    }

    initialize() {
      this.pieces = new Pieces(this)
      this.render("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
      this.showPieces()
      this.dragAndDrop = new DragAndDrop(this)
      this.listenToEvents()
      this.dragAndDrop.init()
    }

    listenToEvents() {
      this.listenTo(d, "fen:set", (fen) => {
        this.render(fen)
      })
      this.listenTo(d, "move:make", (move) => {
        let c = new Chess
        c.load(this.fen)
        c.move(move)
        d.trigger("fen:set", c.fen())
      })
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
      this.fen = fen
    }

    showPieces() {
      setTimeout(() => {
        $(".piece").removeClass("invisible")
      }, 100)
    }

    animating() {
      return !!this.$el.find(".piece:animated").length
    }

    $getSquare(id) {
      return $(`#${id}`)
    }

  }


  Views.Chessboard = Chessboard

}
