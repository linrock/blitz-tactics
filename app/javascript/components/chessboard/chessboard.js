// Basic chessboard that just renders positions

import $ from 'jquery'
import Backbone from 'backbone'
import Chess from 'chess.js'

import Pieces from './concerns/pieces'
import DragAndDrop from './concerns/drag_and_drop'
import PointAndClick from './concerns/point_and_click'
import d from '../../dispatcher'


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
    this.listenTo(d, "fen:set", fen => {
      this.clearHighlights()
      this.render(fen)
    })
    this.listenTo(d, "move:make", (move, highlight = true) => {
      this.clearHighlights()
      const c = new Chess
      c.load(this.fen)
      const moveObj = c.move(move)
      d.trigger("fen:set", c.fen())
      if (moveObj && highlight) {
        d.trigger("move:highlight", moveObj)
      }
    })
    this.listenTo(d, "board:flip", () => {
      this.flipBoard()
    })
    this.listenTo(d, "move:highlight", move => {
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
    const c = new Chess(this.fen)
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
    this.$(".square").each((i, sq) => $(sq).prependTo(this.$el))
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
