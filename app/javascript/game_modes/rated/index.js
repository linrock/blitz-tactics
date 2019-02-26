import PuzzlePlayer from '../../components/puzzle_player'
import Sidebar from './views/sidebar'
import Modal from './views/modal'
import { ratedPuzzleAttempted } from '../../api/requests'
import { dispatch, subscribe } from '../../store'
import { moveToUci } from '../../utils'

const apiPath = `/rated/puzzles`
const fetchThreshold = 5 // fetch more puzzles when this # puzzles remain

export default class Rated {
  constructor() {
    new Sidebar
    new Modal

    let gameStarted = false
    let puzzleId
    let moveSequence = []
    let t0

    const attemptPuzzle = (puzzleId, moveSequence) => {
      const elapsedTimeMs = +new Date() - t0
      const uciMoves = moveSequence.slice(1).map(m => moveToUci(m))
      ratedPuzzleAttempted(puzzleId, uciMoves, elapsedTimeMs).then(data => {
        dispatch(`rated_puzzle:attempted`, data)
      })
    }

    subscribe({
      'puzzle:loaded': current => {
        const puzzle = current.puzzle
        puzzleId = puzzle.id
        t0 = +new Date()
      },

      'puzzles:next': () => gameStarted = true,

      'move:make': move => {
        if (gameStarted) {
          moveSequence.push(move)
        }
      },

      'move:almost': move => {
        if (gameStarted) {
          moveSequence.push(move)
        }
      },

      'move:fail': move => {
        if (!gameStarted) {
          gameStarted = true
          dispatch(`puzzles:next`)
          moveSequence = []
          return
        }
        moveSequence.push(move)
        attemptPuzzle(puzzleId, moveSequence)
        moveSequence = []
        dispatch(`puzzles:next`)
      },

      'puzzle:solved': () => {
        if (!gameStarted) {
          gameStarted = true
          moveSequence = []
          return
        }
        attemptPuzzle(puzzleId, moveSequence)
        moveSequence = []
      },

      'puzzles:status': status => {
        const { i, n, lastPuzzleId } = status
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
      mode: 'rated',
    })
  }
}
