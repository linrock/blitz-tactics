import Chess from 'chess.js'

import { dispatch, subscribe } from '@blitz/store'
import { FEN, MoveColor } from '@blitz/types'
import { uciToMove, getConfig } from '@blitz/utils'
import StockfishEngine from '@blitz/workers/stockfish_engine'

import InteractiveBoard from '../interactive_board'
import Instructions from './views/instructions'
import Actions from './views/actions'

import './style.sass'

type GameResult = '1-0' | '0-1' | '1/2-1/2'

const SEARCH_DEPTH = 15
const START_FEN: FEN = `rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1`

export default class PositionTrainer {
  private depth: number
  private engine: StockfishEngine
  private currentFen: FEN

  constructor() {
    new InteractiveBoard
    this.listenForEvents()
    if (this.computerColor === `w`) {
      dispatch(`board:flip`)
    }
    this.depth = parseInt(getConfig(`depth`), 10) || SEARCH_DEPTH
    this.engine = new StockfishEngine
    this.setDebugHelpers()
    dispatch(`fen:set`, this.initialFen)
    new Instructions({ fen: this.initialFen })
    new Actions()
  }

  private get initialFen(): FEN {
    let fen = getConfig(`fen`) || START_FEN
    return fen.length === 4 ? `${fen} - -` : fen
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
        dispatch(`fen:set`, this.initialFen)
      },

      'fen:set': fen => {
        this.currentFen = fen
        const analysisOptions = {
          depth: this.depth,
          multipv: 1
        }
        this.engine.analyze(fen, analysisOptions).then(output => {
          const { fen, state } = output
          const computerMove = state.evaluation.best
          if (fen !== this.currentFen) {
            return
          }
          if (this.isComputersTurn(fen)) {
            dispatch(`move:make`, uciToMove(computerMove), { opponent: true })
          }
        })
        this.notifyIfGameOver(fen)
      },

      'move:try': move => dispatch(`move:make`, move),
    })
  }

  private notifyIfGameOver(fen: FEN) {
    let c = new Chess
    c.load(fen)
    if (!c.game_over()) {
      return
    }
    let result: GameResult
    if (c.in_draw()) {
      result = `1/2-1/2`
    } else if (c.turn() === `b`) {
      result = `1-0`
    } else {
      result = `0-1`
    }
    setTimeout(() => dispatch(`game:over`, result), 500)
  }
}
