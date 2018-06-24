// Basic chessboard that just renders positions

import Backbone from 'backbone'
import Chess from 'chess.js'

import Pieces from './concerns/pieces'
import DragAndDrop from './concerns/drag_and_drop'
import PointAndClick from './concerns/point_and_click'
import d from '../../dispatcher'

const columns = ['a','b','c','d','e','f','g','h']

export default class Chessboard extends Backbone.View {

  get el() {
    return `.chessboard`
  }

  initialize() {
    this.cjs = new Chess()
    this.pieces = new Pieces(this)
    this.dragAndDrop = new DragAndDrop(this)
    this.pointAndClick = new PointAndClick(this)
    // this.render(`rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1`)
    this.listenToEvents()
    this.dragAndDrop.init()
  }

  listenToEvents() {
    this.listenTo(d, `fen:set`, fen => {
      this.clearHighlights()
      this.render(fen)
    })
    this.listenTo(d, `move:make`, (move, highlight = true) => {
      this.clearHighlights()
      this.cjs.load(this.fen)
      const moveObj = this.cjs.move(move)
      d.trigger(`fen:set`, this.cjs.fen())
      if (moveObj && highlight) {
        d.trigger(`move:highlight`, moveObj)
      }
    })
    this.listenTo(d, `board:flip`, () => {
      this.flipBoard()
    })
    this.listenTo(d, `move:highlight`, move => {
      this.clearHighlights()
      setTimeout(() => {
        this.highlightSquare(move.from, { className: `move-from` })
        this.highlightSquare(move.to, { className: `move-to` })
      }, 10)
    })
  }

  render(fen) {
    if (fen.split(` `).length === 4) {
      fen += ` 0 1`
    }
    this.renderFen(fen)
    this.dragAndDrop.initDraggable()
  }

  renderFen(fen) {
    this.cjs.load(fen)
    this.pieces.reset()
    for (let row = 8; row > 0; row--) {
      for (let j = 0; j < 8; j++) {
        let squareId = columns[j] + row
        let piece = this.cjs.get(squareId)
        if (piece) {
          this.pieces.$getPiece(piece).appendTo(this.$getSquare(squareId))
        }
      }
    }
    this.fen = fen
  }

  movePiece($piece, move) {
    const { from, to } = move
    if (($piece.hasClass(`wp`) && from[1] === `7` && to[1] === `8`) ||
        ($piece.hasClass(`bp`) && from[1] === `2` && to[1] === `1`)) {
      d.trigger(`move:promotion`, { fen: this.fen, move })
    } else {
      this.cjs.load(this.fen)
      const m = this.cjs.move(move)
      if (m) {
        d.trigger(`move:try`, m)
      }
    }
  }

  animating() {
    return !!this.$el.find(`.piece:animated`).length
  }

  flipBoard() {
    this.$(`.square`).each((i, sq) => this.$(sq).prependTo(this.$el))
  }

  clearHighlights() {
    this.$(`.square.highlighted`).removeClass(`highlighted move-from move-to`)
  }

  highlightSquare(id, options) {
    if (!options.className) {
      return
    }
    this.$getSquare(id).addClass(`highlighted ${options.className}`)
  }

  $getSquare(id) {
    return this.$(`#${id}`)
  }
}
