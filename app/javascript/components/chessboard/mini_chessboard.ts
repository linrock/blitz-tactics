import m from 'mithril'
import Chess from 'chess.js'

import virtualPiece from './concerns/pieces.ts'
import { FEN, UciMove } from '../../types.ts'
import { uciToMove } from '../../utils.ts'

interface MiniChessboardOptions {
  el: HTMLElement
  fen: FEN
  initialMove?: UciMove
}

const rows = [8, 7, 6, 5, 4, 3, 2, 1]
const columns = [`a`, `b`, `c`, `d`, `e`, `f`, `g`, `h`]
const polarities = [`light`, `dark`]

export default class MiniChessboard {
  private el: HTMLElement
  private cjs: Chess
  private highlights: {
    [squareId: string]: string
  }

  constructor(options: MiniChessboardOptions) {
    this.el = options.el
    this.cjs = new Chess()
    this.highlights = {}
    this.renderFen(options.fen)
    if (options.initialMove) {
      setTimeout(() => {
        const { from, to } = this.cjs.move(uciToMove(options.initialMove))
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
    for (let row of rows) {
      for (let col of columns) {
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
