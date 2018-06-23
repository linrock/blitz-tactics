import PuzzlePlayer from '../../components/puzzle_player'
import Instructions from './views/instructions'
import Timer from './views/timer'
import Progress from './views/progress'
import SpeedrunComplete from './views/speedrun_complete'
import { speedrunCompleted } from '../../api/requests'
import Listener from '../../listener'
import d from '../../dispatcher'

export default class Speedrun {
  constructor() {
    new Instructions
    new Timer
    new Progress
    new SpeedrunComplete

    new Listener({
      "timer:stopped": elapsedTimeMs => {
        speedrunCompleted('quick', elapsedTimeMs).then(data => {
          d.trigger("speedrun:complete", data)
        })
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      source: `/speedrun/puzzles`
    })
  }
}
