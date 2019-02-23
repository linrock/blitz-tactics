// Basic chessboard that just renders positions

import _ from 'underscore'
import m from 'mithril'
import Chess from 'chess.js'

import { FEN, ChessMove } from '../../types'
import { makeDraggable, makeDroppable } from './concerns/drag_and_drop'
import PointAndClick from './concerns/point_and_click'
import virtualPiece from './concerns/pieces'
import Listener from '../../listener'
import d from '../../dispatcher'

interface HighlightedSquares {
  [squareId: string]: false | {
    [attribute: string]: string
  }
}

interface MoveOptions {
  opponent?: boolean
}

export default class Chessboard {
  private rows = [8, 7, 6, 5, 4, 3, 2, 1]
  private columns = [`a`, `b`, `c`, `d`, `e`, `f`, `g`, `h`]
  private polarities = [`light`, `dark`]
  private fen: FEN
  private highlightedSquares: HighlightedSquares
  public cjs: Chess
  public isFlipped: boolean

  get el() {
    return document.querySelector(`.chessboard`)
  }

  constructor() {
    this.isFlipped = false
    this.cjs = new Chess()
    this.disableMobileDragScroll()
    this.listenToEvents()
    new PointAndClick(this)
  }

  private disableMobileDragScroll(): void {
    this.el.addEventListener('touchmove', event => event.preventDefault())
  }

  private listenToEvents(): void {
    new Listener({
      'fen:set': fen => {
        this.clearHighlights()
        this.renderFen(fen)
      },

      'move:make': (move, options: MoveOptions = {}) => {
        const highlight = options.opponent
        this.clearHighlights()
        this.cjs.load(this.fen)
        const moveObj = this.cjs.move(move)
        d.trigger(`fen:set`, this.cjs.fen())
        if (moveObj && highlight) {
          d.trigger(`move:highlight`, moveObj)
        }
      },

      'board:flip': () => this.flipBoard(),

      'board:flipped': shouldBeFlipped => {
        if (shouldBeFlipped !== this.isFlipped) {
          this.flipBoard()
        }
      },

      'move:highlight': move => {
        this.clearHighlights()
        setTimeout(() => {
          this.highlightSquare(move.from, `data-from`)
          this.highlightSquare(move.to, `data-to`)
          this.renderVirtualDom()
        }, 10)
      }
    })
  }

  private renderFen(fen: FEN): void {
    if (fen.split(` `).length === 4) {
      fen += ` 0 1`
    }
    this.cjs.load(fen)
    this.fen = fen
    this.renderVirtualDom()
  }

  public renderVirtualDom(): void {
    requestAnimationFrame(() => m.render(this.el, this.virtualSquares()))
  }

  public tryMove(move: ChessMove): void {
    const { from, to } = move
    const piece = this.cjs.get(from)
    if (!piece) {
      return
    }
    const { color, type } = piece
    if (type === `p` &&
        ((color === `w` && from[1] === `7` && to[1] === `8`) ||
         (color === `b` && from[1] === `2` && to[1] === `1`))) {
      const validMoves: Array<ChessMove> = this.cjs.moves({ verbose: true })
      if (_.find(validMoves, m => m.from === from && m.to === to)) {
        d.trigger(`move:promotion`, { fen: this.fen, move })
      }
    } else {
      const m: ChessMove = new Chess(this.fen).move(move)
      if (m) {
        d.trigger(`move:try`, m)
      }
    }
  }

  private flipBoard(): void {
    this.isFlipped = !this.isFlipped
    this.columns.reverse()
    this.rows.reverse()
    this.renderVirtualDom()
  }

  private clearHighlights(): void {
    this.highlightedSquares = {}
  }

  // using data attributes to highlight because classes have
  // some weird bug (all classes get removed) when removing classes
  // with mithril
  public highlightSquare(id, attr): void {
    this.highlightedSquares[id] = { [attr]: `highlighted` }
  }

  public unhighlightSquare(id): void {
    this.highlightedSquares[id] = {}
  }

  public virtualSquares(): m.Component {
    let i = 0
    const squares = []
    for (let j = 0; j < 8; j++) {
      for (let k = 0; k < 8; k++) {
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
          oncreate: vnode => makeDroppable(vnode.dom, move => this.tryMove(move)),
          id,
        }
        if (this.highlightedSquares[id]) {
          Object.assign(squareAttrs, this.highlightedSquares[id])
        }
        squares.push(m(`div.square.${polarity}`, squareAttrs, squareEls))
        i += 1
      }
      i += 1
    }
    return squares
  }
}
