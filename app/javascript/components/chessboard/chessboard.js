// Basic chessboard that just renders positions

import m from 'mithril'
import Backbone from 'backbone'
import Chess from 'chess.js'

import { makeDraggable, makeDroppable } from './concerns/drag_and_drop'
import virtualPiece from './concerns/pieces'
import PointAndClick from './concerns/point_and_click'
import d from '../../dispatcher'

export default class Chessboard extends Backbone.View {

  get el() {
    return `.chessboard`
  }

  initialize() {
    this.flipped = false
    this.rows = [8, 7, 6, 5, 4, 3, 2, 1]
    this.columns = [`a`, `b`, `c`, `d`, `e`, `f`, `g`, `h`]
    this.polarities = [`light`, `dark`]
    this.highlights = {}
    this.cjs = new Chess()
    this.pointAndClick = new PointAndClick(this)
    this.listenToEvents()
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
        this.highlightSquare(move.from, `data-from`)
        this.highlightSquare(move.to, `data-to`)
        this.renderVirtualDom()
      }, 10)
    })
    this.listenTo(d, `piece:move`, (pieceEl, move) => {
      this.movePiece(pieceEl, move)
    })
  }

  render(fen) {
    if (fen.split(` `).length === 4) {
      fen += ` 0 1`
    }
    this.renderFen(fen)
  }

  renderFen(fen) {
    this.cjs.load(fen)
    this.fen = fen
    this.renderVirtualDom()
  }

  renderVirtualDom() {
    requestAnimationFrame(() => m.render(this.$el[0], this.virtualSquares()))
  }

  movePiece(pieceEl, move) {
    const { from, to } = move
    if ((pieceEl.classList.contains(`wp`) && from[1] === `7` && to[1] === `8`) ||
        (pieceEl.classList.contains(`bp`) && from[1] === `2` && to[1] === `1`)) {
      d.trigger(`move:promotion`, { fen: this.fen, move })
    } else {
      this.cjs.load(this.fen)
      const m = this.cjs.move(move)
      if (m) {
        d.trigger(`move:try`, m)
      }
    }
  }

  flipBoard() {
    this.flipped = !this.flipped
    this.columns.reverse()
    this.rows.reverse()
    this.renderVirtualDom()
  }

  clearHighlights() {
    this.highlights = {}
  }

  // using data attributes to highlight because classes have
  // some weird bug when removing classes with mithril
  highlightSquare(id, attr) {
    this.highlights[id] = { [attr]: `highlighted` }
  }

  virtualSquares() {
    let i = 0
    const squares = []
    for (let j = 0, r = this.rows.length; j < r; j++) {
      for (let k = 0, c = this.columns.length; k < c; k++) {
        const row = this.rows[j]
        const col = this.columns[k]
        const polarity = this.polarities[i % 2]
        const id = `${col}${row}`
        const squareEls = []
        if (j === 7) {
          squareEls.push(m(`div.square-label.col.${polarity}`, {}, col))
        }
        if (k === 0) {
          squareEls.push(m(`div.square-label.row.${polarity}`, {}, row))
        }
        const piece = this.cjs.get(id)
        if (piece) {
          squareEls.push(virtualPiece(piece, vnode => makeDraggable(vnode.dom)))
        }
        const squareAttrs = {
          'data-square': id,
          oncreate: vnode => makeDroppable(vnode.dom, (pieceEl, move) => {
            d.trigger(`piece:move`, pieceEl, move)
          }),
          id,
        }
        if (this.highlights[id]) {
          Object.assign(squareAttrs, this.highlights[id])
        }
        squares.push(m(`div.square.${polarity}`, squareAttrs, squareEls))
        i += 1
      }
      i += 1
    }
    return squares
  }
}
