// Basic chessboard that just renders positions

import $ from 'jquery'
require('jquery-ui/ui/widgets/droppable')

import m from 'mithril'
import Backbone from 'backbone'
import Chess from 'chess.js'

import Pieces from './concerns/pieces'
import { makeDraggable, makeDroppable } from './concerns/drag_and_drop'
import PointAndClick from './concerns/point_and_click'
import d from '../../dispatcher'

const rows = [8, 7, 6, 5, 4, 3, 2, 1]
const columns = [`a`, `b`, `c`, `d`, `e`, `f`, `g`, `h`]
const polarities = [`light`, `dark`]

function getPiece(piece) {
  const className = piece.color + piece.type
  return m(
    `svg.piece.${className}.${piece.color}`, {
      viewBox: `0 0 45 45`,
      oncreate: vnode => makeDraggable(vnode.dom),
    }, [
      m(`use`, {
        'xlink:href': `#${className}`,
        width: `100%`,
        height: `100%`
      })
    ]
  )
}

export default class Chessboard extends Backbone.View {

  get el() {
    return `.chessboard`
  }

  initialize() {
    this.initializedDroppable = false
    this.highlights = {}
    this.cjs = new Chess()
    this.pieces = new Pieces(this)
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
    this.listenTo(d, `piece:move`, ($piece, move) => this.movePiece($piece, move))
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
    console.log(`rendering virtual dom`)
    requestAnimationFrame(() => m.render(this.$el[0], this.virtualSquares()))
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

  flipBoard() {
    this.$(`.square`).each((i, sq) => this.$(sq).prependTo(this.$el))
  }

  clearHighlights() {
    this.highlights = {}
    this.renderVirtualDom()
  }

  // using data attributes to highlight because classes have
  // some weird bug when removing classes with mithril
  highlightSquare(id, attr) {
    this.highlights[id] = { [attr]: `highlighted` }
  }

  virtualSquares() {
    let i = 0
    const squares = []
    for (let row of rows) {
      for (let col of columns) {
        let id = col + row
        const squareEls = []
        const polarity = polarities[i % 2]
        const piece = this.cjs.get(id)
        if (row === 1) {
          squareEls.push(m(`div.square-label.col.${polarity}`, {}, col))
        }
        if (col === `a`) {
          squareEls.push(m(`div.square-label.row.${polarity}`, {}, row))
        }
        if (piece) {
          squareEls.push(getPiece(piece))
        }
        const squareAttrs = {
          'data-square': id,
          oncreate: vnode => makeDroppable(vnode.dom, ($piece, move) => {
            d.trigger(`piece:move`, $piece, move)
          })
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
