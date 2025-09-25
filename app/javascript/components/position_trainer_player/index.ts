import { subscribe, dispatch } from '@blitz/events'
import { getConfig } from '@blitz/utils'
import ChessgroundBoard from '../chessground_board'
import ChessboardResizer from '../puzzle_player/views/chessboard_resizer'
import Instructions from '../puzzle_player/views/instructions'
import StockfishEngine from '../../workers/stockfish_engine'
import { Chess, Move } from 'chess.js'
import { uciToMove } from '@blitz/utils'
import { FEN } from '@blitz/types'

import '../puzzle_player/style.sass'

interface PositionTrainerOptions {
  fen?: string
  goal?: 'win' | 'draw'
  depth?: number
  noResizer?: boolean
}

type GameResult = '1-0' | '0-1' | '1/2-1/2'

const SEARCH_DEPTH = 15
const START_FEN: FEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

/** Position trainer that reuses puzzle player infrastructure with engine support */
export default class PositionTrainerPlayer {
  private chessgroundBoard: ChessgroundBoard
  private chessboardResizer: ChessboardResizer
  private instructions: Instructions
  private engine: StockfishEngine
  private depth: number
  private initialFen: FEN
  private goal: 'win' | 'draw'
  private computerColor: 'w' | 'b'
  private result: GameResult | null = null

  constructor(options: PositionTrainerOptions = {}) {
    // Get configuration from options or config
    const fen = options.fen || getConfig('fen') || START_FEN
    this.initialFen = fen.split(' ').length === 4 ? `${fen} 0 1` : fen
    this.goal = options.goal || (getConfig('goal') as 'win' | 'draw') || 'win'
    this.depth = options.depth || parseInt(getConfig('depth'), 10) || SEARCH_DEPTH
    
    // Determine computer color based on initial position
    this.computerColor = this.initialFen.indexOf('w') > 0 ? 'b' : 'w'
    
    // Initialize engine
    this.engine = new StockfishEngine
    
    // Create chessboard with proper configuration
    this.chessgroundBoard = new ChessgroundBoard({
      fen: this.initialFen,
      intentOnly: false,
      orientation: this.computerColor === 'w' ? 'black' : 'white',
    })
    
    // Add resizer if not disabled
    if (!options.noResizer) {
      this.chessboardResizer = new ChessboardResizer()
    }
    
    // Add instructions
    this.instructions = new Instructions()
    
    // Set up event subscriptions
    this.setupEventSubscriptions()
    
    // Show initial instructions
    this.showInstructions()
  }

  private setupEventSubscriptions() {
    subscribe({
      'position:reset': () => {
        this.resetPosition()
      },
      
      'fen:updated': (fen: FEN) => {
        this.handleFenUpdate(fen)
      },
      
      'move:try': (move: Move) => {
        this.handlePlayerMove(move)
      },
      
      'move:make': (move: Move, options: { opponent?: boolean } = {}) => {
        if (options.opponent) {
          this.handleComputerMove(move)
        }
      }
    })
  }

  private showInstructions() {
    const toMove = this.initialFen.indexOf('w') > 0 ? 'White' : 'Black'
    let instructionText: string
    
    if (this.goal === 'win') {
      instructionText = `${toMove} to play and win`
    } else if (this.goal === 'draw') {
      instructionText = `${toMove} to play and draw`
    } else {
      instructionText = `${toMove} to move`
    }
    
    dispatch('instructions:set', instructionText)
  }

  private resetPosition() {
    this.chessgroundBoard.unfreeze()
    dispatch('fen:set', this.initialFen)
    this.result = null
    this.showInstructions()
  }

  private handleFenUpdate(fen: FEN) {
    // Analyze position with engine
    const analysisOptions = { depth: this.depth, multipv: 1 }
    this.engine.analyze(fen, analysisOptions).then(output => {
      const { fen: analyzedFen, state } = output
      if (!state) {
        console.warn(`missing state in engine output: ${JSON.stringify(output)}`)
        return
      }
      
      // Check if this is still the current position
      if (analyzedFen !== this.chessgroundBoard.getFen()) {
        return
      }
      
      // If it's the computer's turn, make the move
      if (this.isComputersTurn(fen)) {
        const computerMove = state.evaluation.best
        dispatch('move:make', uciToMove(computerMove), { opponent: true })
      }
    })
    
    // Check for game over
    this.checkGameOver(fen)
  }

  private handlePlayerMove(move: Move) {
    // Hide instructions when player makes a move
    dispatch('instructions:hide')
    dispatch('move:make', move)
  }

  private handleComputerMove(move: Move) {
    // Computer made a move, check for game over
    this.checkGameOver(this.chessgroundBoard.getFen())
  }

  private isComputersTurn(fen: FEN): boolean {
    return fen.includes(` ${this.computerColor} `)
  }

  private checkGameOver(fen: FEN): void {
    const cjs = new Chess(fen)
    if (!cjs.game_over()) {
      return
    }
    
    let result: GameResult
    if (cjs.in_draw()) {
      result = '1/2-1/2'
    } else if (cjs.turn() === 'b') {
      result = '1-0'
    } else {
      result = '0-1'
    }
    
    this.result = result
    this.chessgroundBoard.freeze()
    
    // Show game over message
    setTimeout(() => {
      this.showGameOverMessage(result)
    }, 300)
  }

  private showGameOverMessage(result: GameResult): void {
    const toMove = this.initialFen.indexOf('w') > 0 ? 'White' : 'Black'
    let message: string
    
    if (this.goal === 'win') {
      if ((toMove === 'White' && result === '1-0') ||
          (toMove === 'Black' && result === '0-1')) {
        message = 'You win!!'
      } else {
        message = 'You failed :('
      }
    } else if (this.goal === 'draw' && result === '1/2-1/2') {
      message = 'Success!!'
    } else {
      message = 'Game over'
    }
    
    dispatch('instructions:set', message)
  }

  public getFen(): FEN {
    return this.chessgroundBoard.getFen()
  }

  public analyzeOnLichess(): void {
    const fen = this.getFen()
    window.open(`https://lichess.org/analysis/standard/${fen.replace(/\s+/g, '_')}`)
  }

  public destroy(): void {
    if (this.chessboardResizer) {
      this.chessboardResizer.destroy()
    }
    // Note: ChessgroundBoard and other components don't have destroy methods
    // but they clean up their own event listeners
  }
}