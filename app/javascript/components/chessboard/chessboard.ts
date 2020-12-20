// Basic chessboard that just renders positions

import _ from 'underscore'
import m from 'mithril'
import { Chess, ChessInstance, ShortMove, Square } from 'chess.js'

import { dispatch, subscribe } from '@blitz/events'
import { FEN } from '@blitz/types'
import virtualPiece from './concerns/pieces'

import './chessboard.sass'

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
  public cjs: ChessInstance
  public isFlipped: boolean

  get el() {
    return document.querySelector(`.chessboard`)
  }

  constructor() {
    this.isFlipped = false
    this.cjs = new Chess()
    this.disableMobileDragScroll()
    this.listenToEvents()
  }

  private disableMobileDragScroll(): void {
    this.el.addEventListener('touchmove', event => event.preventDefault())
  }

  private listenToEvents(): void {
    subscribe({
      'fen:set': fen => {
        this.clearHighlights()
        this.renderFen(fen)
      },

      'move:make': (move, options: MoveOptions = {}) => {
        const highlight = options.opponent
        this.clearHighlights()
        this.cjs.load(this.fen)
        const moveObj = this.cjs.move(move)
        dispatch(`fen:set`, this.cjs.fen())
        if (moveObj && highlight) {
          dispatch(`move:highlight`, moveObj)
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

  public tryMove(move: ShortMove): void {
    const { from, to } = move
    const piece = this.cjs.get(from as Square)
    if (!piece) {
      return
    }
    const { color, type } = piece
    if (type === `p` &&
        ((color === `w` && from[1] === `7` && to[1] === `8`) ||
         (color === `b` && from[1] === `2` && to[1] === `1`))) {
      const validMoves = this.cjs.moves({ verbose: true })
      if (validMoves.find(m => m.from === from && m.to === to)) {
        dispatch(`move:promotion`, { fen: this.fen, move })
      }
    } else {
      const m = new Chess(this.fen).move(move)
      if (m) {
        dispatch('move:try', m)
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
  public highlightSquare(id: Square, attr): void {
    this.highlightedSquares[id] = { [attr]: `highlighted` }
  }

  public unhighlightSquare(id: Square): void {
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
        const piece = this.cjs.get(id as Square)
        if (piece) {
          squareEls.push(virtualPiece(piece))
        }
        const squareAttrs = {
          'data-square': id,
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
