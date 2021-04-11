import {
  repetitionLevelAttempted,
  repetitionLevelCompleted
} from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import { dispatch, subscribe } from '@blitz/events'

import Background from './views/background'
import LevelIndicator from './views/level_indicator'
import Onboarding from './views/onboarding'
import ProgressBar from './views/progress_bar'
import Timer from './views/timer'
import HighScores from './views/high_scores'
import LevelStatus from './models/level_status'

import './style.sass'
import './responsive.sass'

export default function RepetitionMode() {
  new Background
  new LevelIndicator
  new Onboarding
  new ProgressBar
  new HighScores
  new Timer

  const level = new LevelStatus()
  const levelPath = (document.querySelector('.repetition-mode') as HTMLElement)
    .dataset.level

  new PuzzlePlayer({
    shuffle: true,
    loopPuzzles: true,
    source: `${window.location.pathname}/puzzles.json`,
  })

  subscribe({
    // level and round completion events
    'round:complete': elapsedTimeMs => {
      repetitionLevelAttempted(levelPath, elapsedTimeMs)
    },

    // level progress events
    'puzzles:fetched': puzzles => {
      level.setNumPuzzles(puzzles.length)
    },

    'puzzles:next': () => {
      level.nextPuzzle()
      dispatch(`progress:update`, level.getProgress())
      if (!level.completed && level.nextLevelUnlocked()) {
        level.completed = true
        repetitionLevelCompleted(levelPath).then(data => {
          dispatch(`level:high_scores`, data.high_scores)
          dispatch(`level:unlocked`, data.next.href)
        })
      }
    },

    'move:fail': () => {
      level.resetProgress()
      dispatch(`progress:update`, 0)
    },

    'move:too_slow': () => {
      level.resetProgress()
      dispatch(`progress:update`, 0)
    },
  })
}
