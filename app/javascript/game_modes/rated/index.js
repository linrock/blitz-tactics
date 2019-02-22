import PuzzlePlayer from '../../components/puzzle_player'
import Sidebar from './views/sidebar'
import Modal from './views/modal'
import { ratedPuzzleAttempted } from '../../api/requests'
import Listener from '../../listener'
import d from '../../dispatcher'
import { moveToUci } from '../../utils'

const apiPath = `/rated/puzzles`

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
      console.log(JSON.stringify(moveSequence))
      const uciMoves = moveSequence.slice(1).map(m => moveToUci(m))
      console.log(JSON.stringify(uciMoves))
      ratedPuzzleAttempted(puzzleId, uciMoves, elapsedTimeMs).then(data => {
        console.log(JSON.stringify(data))
        d.trigger(`rated_puzzle:attempted`, data)
      })
    }

    new Listener({
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
          d.trigger(`puzzles:next`)
          moveSequence = []
          return
        }
        moveSequence.push(move)
        console.log(`puzzle failed :( - ${JSON.stringify(moveSequence)}`)
        attemptPuzzle(puzzleId, moveSequence)
        moveSequence = []
        d.trigger(`puzzles:next`)
      },

      'puzzle:solved': () => {
        if (!gameStarted) {
          gameStarted = true
          moveSequence = []
          return
        }
        console.log(`puzzle solved :) - ${JSON.stringify(moveSequence)}`)
        attemptPuzzle(puzzleId, moveSequence)
        moveSequence = []
      },
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: apiPath,
      mode: 'rated',
    })
  }
}
