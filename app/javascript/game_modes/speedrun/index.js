import PuzzlePlayer from '../../components/puzzle_player'
import Sidebar from './views/sidebar'
import Timer from './views/timer'
import Progress from './views/progress'
import SpeedrunComplete from './views/speedrun_complete'
import { speedrunCompleted } from '../../api/requests'
import Listener from '../../listener'
import d from '../../dispatcher'

const apiPath = `/speedrun/puzzles`

export default class Speedrun {
  constructor() {
    new Sidebar
    new Timer
    new Progress
    new SpeedrunComplete

    new Listener({
      'level:selected': name => {
        d.trigger(`source:changed`, `${apiPath}?name=${name}`)
      },

      'timer:stopped': elapsedTimeMs => {
        speedrunCompleted(`quick`, elapsedTimeMs).then(data => {
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
