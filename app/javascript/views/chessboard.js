// Basic chessboard that just renders positions

import $ from 'jquery'
import _ from 'underscore'
import Backbone from 'backbone'
import Chess from 'chess.js'

require('jquery-ui');
require('jquery-ui/ui/widgets/draggable');
require('jquery-ui/ui/widgets/droppable');

// For handling the DOM elements of the pieces on the board
//
class Pieces {

  constructor(board) {
    this.board = board
    this.$buffer = $("<div>").addClass("piece-buffer")
    this.initializeAllPieces()
  }

  initializeAllPieces() {
    _.each(['w','b'], (color) => {
      _.each('rnbqkbnrpppppppp'.split(''), (type) => {
        this.$getPiece({ color: color, type: type })
      })
    })
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
    this.initDroppable()
    this.initialized = true
  }

  initDraggable() {
    this.board.$(".piece:not(.ui-draggable)").draggable({
      stack: ".piece",
      distance: 10,
      revert: true,
      revertDuration: 0,
      containment: "body",
      scroll: false
    })
  }

  initDroppable() {
    this.board.$(".square").droppable({
      accept: ".piece",
      tolerance: "pointer",
      drop: (event, ui) => {
        let $piece = $(ui.draggable)
        let move = {
          from: $piece.parents(".square").data("square"),
          to: $(event.target).data("square")
        }
        this.board.movePiece($piece, move)
      }
    })
  }

}


// Point and click pieces to select and move them
//
class PointAndClick {

  constructor(board) {
    this.board = board
    this.moveablePieces = ".piece.w"
    this.selectedSquare = false
    this.listenForEvents()
  }

  listenForEvents() {
    this.board.$el.on("click", ".square", (event) => {
      let square = $(event.currentTarget).data("square")
      this.selectSquare(square)
    })
    this.board.listenTo(d, "move:try", () => {
      this.clearSelected()
    })
    this.board.listenTo(d, "move:make", () => {
      this.clearSelected()
    })
  }

  selectSquare(square) {
    if (this.board.$(`#${square} ${this.moveablePieces}`).length) {
      this.clearSelected()
      this.selectedSquare = square
      this.board.$(`#${this.selectedSquare}`).addClass("selected")
    } else if (this.selectedSquare && square != this.selectedSquare) {
      let move = {
        from: this.selectedSquare,
        to: square
      }
      let $piece = this.board.$(`#${this.selectedSquare} .piece`)
      this.board.movePiece($piece, move)
      this.clearSelected()
    }
  }

  clearSelected() {
    this.selectedSquare = false
    this.board.$(".square.selected").removeClass("selected")
  }

}


export default class Chessboard extends Backbone.View {

  get el() {
    return ".chessboard"
  }

  initialize() {
    this.pieces = new Pieces(this)
    this.dragAndDrop = new DragAndDrop(this)
    this.pointAndClick = new PointAndClick(this)
    // this.render("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
    this.listenToEvents()
    this.dragAndDrop.init()
  }

  listenToEvents() {
    this.listenTo(d, "fen:set", (fen) => {
      this.clearHighlights()
      this.render(fen)
    })
    this.listenTo(d, "move:make", (move) => {
      this.clearHighlights()
      let c = new Chess
      c.load(this.fen)
      c.move(move)
      d.trigger("fen:set", c.fen())
    })
    this.listenTo(d, "board:flip", () => {
      this.flipBoard()
    })
    this.listenTo(d, "move:highlight", (move) => {
      this.clearHighlights()
      setTimeout(() => {
        this.highlightSquare(move.from, { className: "move-from" })
        this.highlightSquare(move.to, { className: "move-to" })
      }, 10)
    })
  }

  render(fen) {
    if (fen.split(" ").length === 4) {
      fen += " 0 1"
    }
    this.renderFen(fen)
    this.dragAndDrop.initDraggable()
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

  movePiece($piece, move) {
    let c = new Chess(this.fen)
    if (($piece.hasClass("wp") || $piece.hasClass("bp")) &&
        (move.to[1] == "8" || move.to[1] == "1")) {
      d.trigger("move:promotion", { fen: this.fen, move: move })
    } else {
      let m = c.move(move)
      if (m) {
        d.trigger("move:try", m)
      }
    }
  }

  animating() {
    return !!this.$el.find(".piece:animated").length
  }

  flipBoard() {
    this.$(".square").each((i,sq) => { $(sq).prependTo(this.$el) })
  }

  clearHighlights() {
    this.$(".square.highlighted").removeClass("highlighted move-from move-to")
  }

  highlightSquare(id, options) {
    if (!options.className) {
      return
    }
    this.$getSquare(id).addClass(`highlighted ${options.className}`)
  }

  $getSquare(id) {
    return $(`#${id}`)
  }

}
