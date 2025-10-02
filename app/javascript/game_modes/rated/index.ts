import { createApp } from 'vue'

import PuzzlePlayer from '@blitz/components/puzzle_player'
import { ratedPuzzleAttempted } from '@blitz/api/requests'
import { dispatch, subscribe, GameEvent } from '@blitz/events'
import { moveToUci } from '@blitz/utils'

import SidebarVue from './sidebar.vue'

import './style.sass'
import './responsive.sass'

const apiPath = `/rated/puzzles.json`
const fetchThreshold = 5 // fetch more puzzles when this # puzzles remain

export default function RatedMode() {
  createApp(SidebarVue).mount('.rated-mode .vue-app-mount')

  let gameStarted = false
  let puzzleId: number
  let moveSequence = []
  let t0: number

  const attemptPuzzle = (puzzleId: number, moveSequence: any[]) => {
    const elapsedTimeMs = +new Date() - t0
    const uciMoves = moveSequence.slice(1).map(m => moveToUci(m))
    ratedPuzzleAttempted(puzzleId, uciMoves, elapsedTimeMs).then(data => {
      dispatch(`rated_puzzle:attempted`, data)
    })
  }

  subscribe({
    [GameEvent.PUZZLE_LOADED]: current => {
      const puzzle = current.puzzle
      puzzleId = puzzle.id
      t0 = +new Date()
    },

    [GameEvent.PUZZLES_NEXT]: () => gameStarted = true,

    [GameEvent.MOVE_MAKE]: move => {
      if (gameStarted) {
        moveSequence.push(move)
      }
    },

    [GameEvent.MOVE_ALMOST]: move => {
      if (gameStarted) {
        moveSequence.push(move)
      }
    },

    [GameEvent.MOVE_FAIL]: move => {
      if (!gameStarted) {
        gameStarted = true
        dispatch(GameEvent.PUZZLES_NEXT)
        moveSequence = []
        return
      }
      moveSequence.push(move)
      attemptPuzzle(puzzleId, moveSequence)
      moveSequence = []
      dispatch(GameEvent.PUZZLES_NEXT)
    },

    [GameEvent.PUZZLE_SOLVED]: () => {
      if (!gameStarted) {
        gameStarted = true
        moveSequence = []
        return
      }
      attemptPuzzle(puzzleId, moveSequence)
      moveSequence = []
    },

    [GameEvent.PUZZLES_STATUS]: status => {
      const { i, n } = status
      console.log(`${i} of ${n}`)
      if (i + fetchThreshold > n) {
        dispatch(`source:changed:add`, `${apiPath}?next=true`)
      }
    }
  })

  new PuzzlePlayer({
    shuffle: false,
    loopPuzzles: false,
    noCombo: true,
    noCounter: true,
    noHint: true,
    source: apiPath,
    mode: 'rated', // TODO fix this hack
  })
}
