<template lang="pug">
aside.countdown-under-board.game-under-board
  .timers(:style="{ display: (hasStarted && !hasFinished) ? '' : 'none'}")
    .current-countdown
      timer
      .description {{ nPuzzlesSolved }} puzzles solved

  .countdown-complete(v-if="hasFinished")
    .score-section
      .score-container.your-score
        .label Your score
        .score {{ score }}

      .score-container.high-score
        .label High score
        .score {{ highScore }}

    .action-buttons
      a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
      a.blue-button(href="/countdown") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { countdownCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { subscribe } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin],

  data() {
    return {
      nPuzzlesSolved: 0,
      score: 0,
      highScore: 0,
    }
  },

  mounted() {
    let levelName: string
    const commonSubscriptions = this.setupCommonSubscriptions()

    // Subscribe to common events first
    subscribe(commonSubscriptions)
    
    // Then subscribe to countdown-specific events
    subscribe({
      'config:init': data => levelName = data.level_name,
      'puzzles:status': ({ i }) => {
        this.nPuzzlesSolved = i + 1
      },
      'puzzle:solved': (puzzle) => {
        // Track individual puzzle solve
        console.log('Countdown puzzle solved:', puzzle)
        if (puzzle && puzzle.id) {
          trackSolvedPuzzle(puzzle.id, 'countdown').catch(error => {
            console.error('Failed to track solved puzzle:', error)
          })
        }
      },
      'timer:stopped': () => {
        this.showBoardOverlay()
        countdownCompleted(levelName, this.nPuzzlesSolved).then(data => {
          const { score, best } = data
          this.score = score
          this.highScore = best
          this.hasFinished = true
        })
        this.saveMistakesToStorage()
      },
      'move:try': move => {
        // Set hasStarted on first move
        if (!this.hasStarted) {
          this.hasStarted = true
        }
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noCounter: true,
      noHint: true,
      source: '/countdown/puzzles.json',
    })
  },

  components: {
    Timer
  }
}
</script>
