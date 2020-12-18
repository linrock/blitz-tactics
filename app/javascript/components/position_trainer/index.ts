import { Chess, Move } from 'chess.js'

import { dispatch, subscribe } from '@blitz/store'
import { FEN, MoveColor } from '@blitz/types'
import { uciToMove, getConfig } from '@blitz/utils'
import StockfishEngine from '@blitz/workers/stockfish_engine'

import ChessgroundBoard from '../chessground_board'
import Instructions from './views/instructions'
import Actions from './views/actions'

import './style.sass'

type GameResult = '1-0' | '0-1' | '1/2-1/2'

const SEARCH_DEPTH = 15
const START_FEN: FEN = `rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1`

export default class PositionTrainer {
  private chessgroundBoard: ChessgroundBoard
  private depth: number
  private engine: StockfishEngine

  constructor() {
    this.chessgroundBoard = new ChessgroundBoard(this.initialFen, {
      intentOnly: false,
      orientation: this.computerColor === 'w' ? 'black' : 'white',
    })
    this.listenForEvents()
    this.depth = parseInt(getConfig(`depth`), 10) || SEARCH_DEPTH
    this.engine = new StockfishEngine
    this.setDebugHelpers()
    new Instructions({ fen: this.initialFen })
    new Actions()
  }

  private get initialFen(): FEN {
    let fen = getConfig(`fen`) || START_FEN
    return fen.split(' ').length === 4 ? `${fen} 0 1` : fen
  }

  private get computerColor(): MoveColor {
    return this.initialFen.indexOf(`w`) > 0 ? `b` : `w`
  }

  private setDebugHelpers() {
    (window as any).analyzeFen = (fen: FEN, depth: number) => {
      this.engine.analyze(fen, { multipv: 1, depth })
    }
  }

  private isComputersTurn(fen: FEN): boolean {
    return fen.indexOf(` ${this.computerColor} `) > 0
  }

  private listenForEvents() {
    subscribe({
      'position:reset': () => {
        this.chessgroundBoard.unfreeze()
        dispatch(`fen:set`, this.initialFen)
      },

      'fen:updated': (fen: FEN) => {
        const analysisOptions = {
          depth: this.depth,
          multipv: 1
        }
        this.engine.analyze(fen, analysisOptions).then(output => {
          const { fen, state } = output
          const computerMove = state.evaluation.best
          if (fen !== this.chessgroundBoard.getFen()) {
            return
          }
          if (this.isComputersTurn(fen)) {
            dispatch(`move:make`, uciToMove(computerMove), { opponent: true })
          }
        })
        this.notifyIfGameOver(fen)
      },

      'move:try': (move: Move) => dispatch(`move:make`, move),
    })
  }

  private notifyIfGameOver(fen: FEN) {
    const cjs = new Chess
    cjs.load(fen)
    if (!cjs.game_over()) {
      return
    }
    let result: GameResult
    if (cjs.in_draw()) {
      result = `1/2-1/2`
    } else if (cjs.turn() === `b`) {
      result = `1-0`
    } else {
      result = `0-1`
    }
    this.chessgroundBoard.freeze()
    setTimeout(() => {
      dispatch(`game:over`, result)
    }, 500)
  }
}
