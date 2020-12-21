<template lang="pug">
.instructions(:class=`{ invisible: !showInstructions && !showGameOver}`)
  | {{ showInstructions ? instructionsText : showGameOver ? gameOverText : '' }}
.chessground-board
  .piece-promotion-modal-container
  .chessground
.actions
  button.dark-button(@click="resetPosition()") Reset position
  button.dark-button(@click="analyzeOnLichess()") Analyze on Lichess

</template>

<script lang="ts">
import { Chess, Move } from 'chess.js'

import { dispatch, subscribe } from '@blitz/events'
import { FEN } from '@blitz/types'
import { uciToMove, getConfig } from '@blitz/utils'
import StockfishEngine from '@blitz/workers/stockfish_engine'
import ChessgroundBoard from '../chessground_board'

import './style.sass'

type GameResult = '1-0' | '0-1' | '1/2-1/2'

const SEARCH_DEPTH = 15
const START_FEN: FEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

let chessgroundBoard: ChessgroundBoard
let depth: number
let engine: StockfishEngine

export default {
  data() {
    const fen = getConfig('fen') || START_FEN
    const goal = getConfig('goal') as 'win' | 'draw'
    return {
      initialFen: fen.split(' ').length === 4 ? `${fen} 0 1` : fen,
      showInstructions: false,
      showGameOver: false,
      gameResult: null,
      goal,
    }
  },

  computed: {
    computerColor(): 'w' | 'b' {
      return this.initialFen.indexOf('w') > 0 ? 'b' : 'w'
    },
    toMove(): 'White' | 'Black' {
      return this.initialFen.indexOf('w') > 0 ? 'White' : 'Black'
    },
    instructionsText(): string {
      if (this.goal === 'win') {
        return this.toMove + ' to play and win'
      } else if (this.goal === 'draw') {
        return this.toMove + ' to play and draw'
      }
      return this.toMove + ' to move'
    },
    gameOverText(): string | undefined {
      if (!this.result) {
        return
      }
      let text: string
      console.log(`goal: ${this.goal}, toMove: ${this.toMove}, result: ${this.result}`)
      if (this.goal === 'win') {
        if ((this.toMove === 'White' && this.result === '1-0') ||
            (this.toMove === 'Black' && this.result === '0-1')) {
          text = 'You win!!'
        } else {
          text = 'You failed :('
        }
      } else if (this.goal === 'draw' && this.result === '1/2-1/2') {
        text = 'Success!!'
      } else {
        text = 'Game over'
      }
      return text
    }
  },

  methods: {
    isComputersTurn(fen: FEN): boolean {
      return fen.includes(` ${this.computerColor} `)
    },
    notifyIfGameOver(fen: FEN): void {
      const cjs = new Chess(fen)
      if (!cjs.game_over()) {
        return
      }
      let result: GameResult
      if (cjs.in_draw()) {
        this.result = '1/2-1/2'
      } else if (cjs.turn() === 'b') {
        this.result = '1-0'
      } else {
        this.result = '0-1'
      }
      chessgroundBoard.freeze()
      setTimeout(() => this.showGameOver = true, 300)
    },
    resetPosition() {
      dispatch('position:reset')
    },
    analyzeOnLichess() {
      console.log(chessgroundBoard.getFen())
      window.open(`https://lichess.org/analysis/standard/${chessgroundBoard.getFen().replace(/\s+/g, '_')}`)
    },
  },

  mounted() {
    chessgroundBoard = new ChessgroundBoard({
      fen: this.initialFen,
      intentOnly: false,
      orientation: this.computerColor === 'w' ? 'black' : 'white',
    })
    depth = parseInt(getConfig('depth'), 10) || SEARCH_DEPTH
    engine = new StockfishEngine
    subscribe({
      'position:reset': () => {
        chessgroundBoard.unfreeze()
        dispatch('fen:set', this.initialFen)
        this.result = null
        this.showGameOver = false
        this.showInstructions = true
      },
      'fen:updated': (fen: FEN) => {
        const analysisOptions = { depth, multipv: 1 }
        engine.analyze(fen, analysisOptions).then(output => {
          const { fen, state } = output
          if (!state) {
            console.warn(`missing state in engine output: ${JSON.stringify(output)}`)
          }
          const computerMove = state.evaluation.best
          if (fen !== chessgroundBoard.getFen()) {
            return
          }
          if (this.isComputersTurn(fen)) {
            dispatch('move:make', uciToMove(computerMove), { opponent: true })
          }
        })
        this.notifyIfGameOver(fen)
      },
      'move:try': (move: Move) => {
        this.showInstructions = false
        dispatch('move:make', move)
      },
      'game:over': result => this.gameOverMan(result),
    })
    // this.setDebugHelpers()
    this.showInstructions = true
  }
}
</script>
