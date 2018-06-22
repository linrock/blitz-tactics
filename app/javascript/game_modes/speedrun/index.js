import PuzzlePlayer from '../../components/puzzle_player'
import Instructions from './views/instructions'
import Progress from './views/progress'
// import Background from './views/background'
import Timer from './views/timer'

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
    new Progress
    new Timer

    // models
    new CompletionNotifier
  }
}
