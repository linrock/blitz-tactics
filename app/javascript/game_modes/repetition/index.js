import PuzzlePlayer from '../../components/puzzle_player'
import Background from './views/background'
import LevelIndicator from './views/level_indicator'
import Onboarding from './views/onboarding'
import ProgressBar from './views/progress_bar'
import Timer from './views/timer'
import HighScores from './views/high_scores'
import LevelStatus from './models/level_status'
import {
  repetitionLevelAttempted,
  repetitionLevelCompleted
} from '../../api/requests'
import { dispatch, subscribe } from '../../store'

export default class RepetitionMode {
  constructor() {
    new Background
    new LevelIndicator
    new Onboarding
    new ProgressBar
    new HighScores
    new Timer

    this.level = new LevelStatus()
    const levelPath = document.querySelector(".repetition-mode").dataset.level

    new PuzzlePlayer({
      shuffle: true,
      loopPuzzles: true,
      source: `${window.location.pathname}/puzzles.json`
    })

    subscribe({
      // level and round completion events
      'round:complete': elapsedTimeMs => {
        repetitionLevelAttempted(levelPath, elapsedTimeMs)
      },

      // level progress events
      'puzzles:fetched': puzzles => {
        this.level.setNumPuzzles(puzzles.length)
      },

      'puzzles:next': () => {
        this.level.nextPuzzle()
        dispatch(`progress:update`, this.level.getProgress())
        if (!this.level.completed && this.level.nextLevelUnlocked()) {
          this.level.completed = true
          repetitionLevelCompleted(levelPath).then(data => {
            dispatch(`level:high_scores`, data.high_scores)
            dispatch(`level:unlocked`, data.next.href)
          })
        }
      },

      'move:fail': () => {
        this.level.resetProgress()
        dispatch(`progress:update`, 0)
      },

      'move:too_slow': () => {
        this.level.resetProgress()
        dispatch(`progress:update`, 0)
      },
    })
  }
}
