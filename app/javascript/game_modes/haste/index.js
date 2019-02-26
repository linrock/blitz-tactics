import PuzzlePlayer from '../../components/puzzle_player'
import Sidebar from './views/sidebar'
import Timer from './views/timer'
import Progress from './views/progress'
import Modal from './views/modal'
import Complete from './views/complete'
import { hasteRoundCompleted } from '../../api/requests'
import { dispatch, subscribe } from '../../store'

const apiPath = `/haste/puzzles`

export default class Haste {
  constructor() {
    new Sidebar
    new Timer
    new Progress
    new Modal
    new Complete

    let levelName

    subscribe({
      'config:init': data => {
        levelName = data.level_name
      },

      'timer:complete': score => {
        hasteRoundCompleted(score).then(data => {
          dispatch(`haste:complete`, data)
        })
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: apiPath,
    })
  }
}
