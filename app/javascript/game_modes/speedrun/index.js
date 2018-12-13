import PuzzlePlayer from '../../components/puzzle_player'
import Sidebar from './views/sidebar'
import Timer from './views/timer'
import Progress from './views/progress'
import Modal from './views/modal'
import SpeedrunComplete from './views/speedrun_complete'
import { speedrunCompleted } from '../../api/requests'
import Listener from '../../listener.ts'
import d from '../../dispatcher.ts'

const apiPath = `/speedrun/puzzles`

export default class Speedrun {
  constructor() {
    new Sidebar
    new Timer
    new Modal
    new Progress
    new SpeedrunComplete

    let levelName

    new Listener({
      'level:selected': name => {
        d.trigger(`source:changed`, `${apiPath}?name=${name}`)
      },

      'config:init': data => {
        levelName = data.level_name
      },

      'timer:stopped': elapsedTimeMs => {
        speedrunCompleted(levelName, elapsedTimeMs).then(data => {
          d.trigger(`speedrun:complete`, data)
        })
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      source: apiPath,
    })
  }
}
