import PuzzlePlayer from '../../components/puzzle_player'
import Background from './views/background'
import LevelIndicator from './views/level_indicator'
import Onboarding from './views/onboarding'
import ProgressBar from './views/progress_bar'
import Timer from './views/timer'
import HighScores from './views/high_scores'
import LevelStatus from './models/level_status.ts'
import {
  repetitionLevelAttempted,
  repetitionLevelCompleted
} from '../../api/requests'
import Listener from '../../listener.ts'
import d from '../../dispatcher.ts'

export default class RepetitionMode {
  constructor() {
    new Background
    new LevelIndicator
    new Onboarding
    new ProgressBar
    new Timer
    new HighScores

    this.level = new LevelStatus()
    this.listenForEvents()

    new PuzzlePlayer({
      shuffle: true,
      loopPuzzles: true,
      source: `${window.location.pathname}/puzzles.json`
    })
  }

  listenForEvents() {
    new Listener({
      // level and round completion events
      'round:complete': (levelPath, elapsedTimeMs) => {
        if (levelPath) {
          repetitionLevelAttempted(levelPath, elapsedTimeMs)
        }
      },

      'level:complete': levelPath => {
        repetitionLevelCompleted(levelPath)
          .then(data => {
            d.trigger(`level:high_scores`, data.high_scores)
            d.trigger(`level:unlocked`, data.next.href)
          })
      },

      // level progress events
      'puzzles:fetched': puzzles => {
        this.level.setNumPuzzles(puzzles.length)
      },

      'puzzles:next': () => {
        this.level.nextPuzzle()
        d.trigger(`progress:update`, this.level.getProgress())
        if (!this.level.completed && this.level.nextLevelUnlocked()) {
          this.level.completed = true
          d.trigger(`level:complete`, blitz.levelPath)
        }
      },

      'move:fail': () => {
        this.level.resetProgress()
        d.trigger(`progress:update`, 0)
      },

      'move:too_slow': () => {
        this.level.resetProgress()
        d.trigger(`progress:update`, 0)
      },
    })
  }
}
