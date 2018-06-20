import PuzzlePlayer from '../puzzle_player'
import Background from './views/background'
import LevelIndicator from './views/level_indicator'
import Onboarding from './views/onboarding'
import ProgressBar from './views/progress_bar'
import Timer from './views/timer'

import LevelProgress from './models/level_progress'
import CompletionNotifier from './models/completion_notifier'

export default class PrecisionMode {
  constructor() {
    // views
    new PuzzlePlayer({
      shuffle: true,
      loopPuzzles: true
    })
    new Background
    new LevelIndicator
    new Onboarding
    new ProgressBar
    new Timer

    // models
    new LevelProgress
    new CompletionNotifier
  }
}
