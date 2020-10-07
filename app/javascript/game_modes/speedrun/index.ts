import { speedrunCompleted } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import { dispatch, subscribe } from '@blitz/store'

import Modal from './views/modal'
import Progress from './views/progress'
import Sidebar from './views/sidebar'
import SpeedrunComplete from './views/speedrun_complete'
import Timer from './views/timer'

import './style.sass'
import './responsive.sass'

const apiPath = `/speedrun/puzzles.json`

export default function SpeedrunMode() {
  new Sidebar
  new Timer
  new Modal
  new Progress
  new SpeedrunComplete

  let levelName: string

  subscribe({
    'config:init': data => levelName = data.level_name,

    'level:selected': name => {
      dispatch(`source:changed`, `${apiPath}?name=${name}`)
    },

    'timer:stopped': elapsedTimeMs => {
      speedrunCompleted(levelName, elapsedTimeMs).then(data => {
        dispatch(`speedrun:complete`, data)
      })
    }
  })

  new PuzzlePlayer({
    shuffle: false,
    loopPuzzles: false,
    source: apiPath,
  })
}
