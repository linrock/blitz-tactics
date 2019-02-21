import PuzzlePlayer from '../../components/puzzle_player'
import Sidebar from './views/sidebar'
import Progress from './views/progress'
import Modal from './views/modal'
import { ratedPuzzleAttempted } from '../../api/requests'
import Listener from '../../listener'
import d from '../../dispatcher'
import { moveToUci } from '../../utils'

const apiPath = `/rated/puzzles`

export default class Rated {
  constructor() {
    new Sidebar
    new Progress
    new Modal

    let puzzleId
    let userMoves = []
    let t0

    new Listener({
      'puzzle:loaded': current => {
        const puzzle = current.puzzle
        puzzleId = puzzle.id
        t0 = +new Date()
      },

      'move:try': move => {
        userMoves.push(move)
      },

      'move:fail': () => {
        console.log('puzzle failed :(')
        console.log(JSON.stringify(userMoves))
        ratedPuzzleAttempted(
          puzzleId,
          userMoves.map(m => moveToUci(m)),
          +new Date() - t0
        )
        d.trigger(`puzzles:next`)
        userMoves = []
      },

      'puzzle:solved': () => {
        console.log('puzzle solved :)')
        console.log(JSON.stringify(userMoves))
        ratedPuzzleAttempted(
          puzzleId,
          userMoves.map(m => moveToUci(m)),
          +new Date() - t0
        )
        userMoves = []
      },
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: apiPath,
    })
  }
}
