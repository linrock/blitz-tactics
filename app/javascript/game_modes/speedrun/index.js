import PuzzlePlayer from '../../components/puzzle_player'
import Instructions from './views/instructions'
import Timer from './views/timer'
import Progress from './views/progress'
import SpeerunComplete from './views/speedrun_complete'
// import Background from './views/background'

import CompletionNotifier from './models/completion_notifier'

export default class Speedrun {
  constructor() {
    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      source: `/speedrun/puzzles`
    })
    new Instructions
    // new Background
    new Timer
    new Progress
    new SpeedrunComplete

    // models
    new CompletionNotifier
  }
}
