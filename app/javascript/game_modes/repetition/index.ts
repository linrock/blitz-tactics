import {
  repetitionLevelAttempted,
  repetitionLevelCompleted,
  trackSolvedPuzzle
} from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import { dispatch, subscribe, subscribeOnce } from '@blitz/events'

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
  const repetitionModeElement = document.querySelector('.repetition-mode') as HTMLElement
  const levelPath = repetitionModeElement?.dataset.level

  new PuzzlePlayer({
    shuffle: true,
    loopPuzzles: true,
    source: `${window.location.pathname}/puzzles`,
  })

  // Hide onboarding message after first move
  subscribeOnce('move:try', () => {
    const onboardingEl = document.querySelector('.onboarding') as HTMLElement
    if (onboardingEl) {
      onboardingEl.style.display = 'none'
    }
  })

  subscribe({
    // In repetition mode, hints should drop the combo indicator
    'puzzle:hint': () => {
      dispatch('combo:drop')
    },

    // Track individual puzzle solves
    'puzzle:solved': (puzzle) => {
      if (puzzle && puzzle.id) {
        trackSolvedPuzzle(puzzle.id).catch(error => {
          console.error('Failed to track solved puzzle:', error)
        })
      }
    },
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
