import { countdownCompleted } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import { dispatch, subscribe } from '@blitz/store'

import Sidebar from './views/sidebar'
import Timer from './views/timer'
import Progress from './views/progress'
import Modal from './views/modal'
import CountdownComplete from './views/countdown_complete'

import './style.sass'
import './responsive.sass'

const apiPath = `/countdown/puzzles.json`

export default function CountdownMode() {
  new Sidebar
  new Timer
  new Progress
  new Modal
  new CountdownComplete

  let levelName

  subscribe({
    'config:init': data => levelName = data.level_name,

    'timer:complete': score => {
      countdownCompleted(levelName, score).then(data => {
        dispatch(`countdown:complete`, data)
      })
    }
  })

  new PuzzlePlayer({
    shuffle: false,
    loopPuzzles: false,
    noCounter: true,
    noHint: true,
    source: apiPath,
  })
}
