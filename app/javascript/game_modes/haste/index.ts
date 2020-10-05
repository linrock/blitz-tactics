import { hasteRoundCompleted } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import { dispatch, subscribe } from '@blitz/store'

import Sidebar from './views/sidebar'
import Timer from './views/timer'
import Progress from './views/progress'
import Modal from './views/modal'
import Complete from './views/complete'

import './style.sass'
import './responsive.sass'

const apiPath = `/haste/puzzles`

export default function HasteMode() {
  new Sidebar
  new Timer
  new Progress
  new Modal
  new Complete

  subscribe({
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
