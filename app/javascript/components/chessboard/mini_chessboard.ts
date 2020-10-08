import m from 'mithril'
import Chess from 'chess.js'

import { FEN, UciMove } from '@blitz/types'
import { uciToMove } from '@blitz/utils'
import virtualPiece from './concerns/pieces'

import './mini_chessboard.sass'

interface MiniChessboardOptions {
  el: HTMLElement
  fen: FEN
  flip?: boolean
  initialMove?: UciMove
  initialMoveSan?: string
}

const polarities = [`light`, `dark`]

export default class MiniChessboard {
  private el: HTMLElement
  private cjs: Chess
  private rows = [8, 7, 6, 5, 4, 3, 2, 1]
  private columns = [`a`, `b`, `c`, `d`, `e`, `f`, `g`, `h`]
  private highlights: {
    [squareId: string]: string
  }

  constructor(options: MiniChessboardOptions) {
    this.el = options.el
    this.cjs = new Chess()
    this.highlights = {}
    if (options.flip) {
      this.rows.reverse()
      this.columns.reverse()
    }
    this.renderFen(options.fen)
    // TODO DRY
    if (options.initialMove) {
      setTimeout(() => {
        const { from, to } = this.cjs.move(uciToMove(options.initialMove))
        this.highlightSquare(from, `move-from`)
        this.highlightSquare(to, `move-to`)
        this.renderFen(this.cjs.fen())
      }, 1000)
    } else if (options.initialMoveSan) {
      setTimeout(() => {
        const { from, to } = this.cjs.move(options.initialMoveSan)
        this.highlightSquare(from, `move-from`)
        this.highlightSquare(to, `move-to`)
        this.renderFen(this.cjs.fen())
      }, 1000)
    }
  }

  private renderFen(fen: FEN): void {
    if (fen.split(` `).length === 4) {
      fen += ` 0 1`
    }
    if (fen !== this.cjs.fen()) {
      this.cjs.load(fen)
    }
    requestAnimationFrame(() => m.render(this.el, this.virtualSquares()))
  }

  private virtualSquares(): m.Component {
    let i = 0
    const squares = []
    for (let row of this.rows) {
      for (let col of this.columns) {
        let id = col + row
        const pieces = []
        const piece = this.cjs.get(id)
        if (piece) {
          pieces.push(virtualPiece(piece))
        }
        const squareAttrs = (<any>{})
        if (this.highlights[id]) {
          squareAttrs.class = this.highlights[id]
        }
        squares.push(m(`div.square.${polarities[i % 2]}`, squareAttrs, pieces))
        i += 1
      }
      i += 1
    }
    return squares
  }

  private highlightSquare(squareId, className): void {
    this.highlights[squareId] = className
  }
}
