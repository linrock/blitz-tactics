<template lang="pug">
.instructions.invisible
.chessground-board
  .piece-promotion-modal-container
  .chessground
.actions
  button.button.restart(@click="resetPosition()") Reset position

</template>

<script lang="ts">
import { Chess, Move } from 'chess.js'

import { dispatch, subscribe } from '@blitz/events'
import { FEN } from '@blitz/types'
import { uciToMove, getConfig } from '@blitz/utils'
import StockfishEngine from '@blitz/workers/stockfish_engine'

import ChessgroundBoard from '../chessground_board'
import Instructions from './views/instructions'

import './style.sass'

type GameResult = '1-0' | '0-1' | '1/2-1/2'

const SEARCH_DEPTH = 15
const START_FEN: FEN = 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'

let chessgroundBoard: ChessgroundBoard
let depth: number
let engine: StockfishEngine

export default {
  data() {
    let fen = getConfig('fen') || START_FEN
    return {
      initialFen: fen.split(' ').length === 4 ? `${fen} 0 1` : fen,
    }
  },

  computed: {
    computerColor(): 'w' | 'b' {
      return this.initialFen.indexOf('w') > 0 ? 'b' : 'w'
    }
  },

  methods: {
    isComputersTurn(fen: FEN): boolean {
      return fen.indexOf(` ${this.computerColor} `) > 0
    },
    notifyIfGameOver(fen: FEN): void {
      const cjs = new Chess
      cjs.load(fen)
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
      chessgroundBoard.freeze()
      setTimeout(() => {
        dispatch('game:over', result)
      }, 500)
    },
    resetPosition() {
      dispatch('position:reset')
    }
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
      'move:try': (move: Move) => dispatch('move:make', move),
    })
    // this.setDebugHelpers()
    new Instructions({ fen: this.initialFen })
  }
}
</script>
