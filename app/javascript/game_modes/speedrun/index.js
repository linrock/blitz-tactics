import PuzzlePlayer from '../../components/puzzle_player'
import Instructions from './views/instructions'
import Timer from './views/timer'
import Progress from './views/progress'
import AboveBoard from './views/above_board'
import { speedrunCompleted } from '../../api/requests'
import Listener from '../../listener'
import d from '../../dispatcher'

export default class Speedrun {
  constructor() {
    new Instructions
    new AboveBoard
    new Timer
    new Progress

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
