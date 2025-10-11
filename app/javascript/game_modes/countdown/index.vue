<template lang="pug">
aside.countdown-under-board.game-under-board
  .timers(:style="{ display: (hasStarted && !hasFinished) ? '' : 'none'}")
    .current-countdown
      timer
      .description {{ nPuzzlesSolved }} puzzles solved

  .countdown-complete(v-if="hasFinished")
    .timers-section
      .timer-container.accuracy(:class="{ 'perfect-accuracy': isPerfectAccuracy }")
        .label Accuracy
        .timer {{ accuracyPercentage }}%

      .timer-container.your-score
        .label Your score
        .timer {{ score }}

      .timer-container.high-score
        .label High score
        .timer {{ highScore }}

    .action-buttons
      a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
      a.blue-button(href="/countdown") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { countdownCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import PuzzleTrackingMixin from '@blitz/components/puzzle_tracking_mixin'
import { subscribe, GameEvent } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin, PuzzleTrackingMixin],

  data() {
    return {
      nPuzzlesSolved: 0,
      score: 0,
      highScore: 0,
      totalMoves: 0,
      correctMoves: 0,
    }
  },

  computed: {
    accuracyPercentage() {
      if (this.totalMoves === 0) return 0
      return Math.round((this.correctMoves / this.totalMoves) * 100)
    },

    isPerfectAccuracy() {
      return this.totalMoves > 0 && this.correctMoves === this.totalMoves
    }
  },

  mounted() {
    let levelName: string
    const commonSubscriptions = this.setupCommonSubscriptions()
    const puzzleTracking = this.setupPuzzleTrackingSubscriptions('countdown', trackSolvedPuzzle)

    // Subscribe to common events first
    subscribe(commonSubscriptions)
    
    // Then subscribe to countdown-specific events
    subscribe({
      ...puzzleTracking,
      [GameEvent.CONFIG_INIT]: data => levelName = data.level_name,
      [GameEvent.PUZZLES_STATUS]: ({ i }) => {
        this.nPuzzlesSolved = i + 1
      },
      [GameEvent.TIMER_STOPPED]: () => {
        this.showBoardOverlay()
        
        // Add unsolved puzzle and show section
        this.addUnsolvedPuzzle()
        
        countdownCompleted(levelName, this.nPuzzlesSolved).then(data => {
          const { score, best } = data
          this.score = score
          this.highScore = best
          this.hasFinished = true
          
          // Show the played puzzles section if there are any
          if (this.playedPuzzles.length > 0) {
            this.showPlayedPuzzlesSection()
          }
        })
        this.saveMistakesToStorage()
      },
      [GameEvent.MOVE_TRY]: move => {
        // Set hasStarted on first move
        if (!this.hasStarted) {
          this.hasStarted = true
        }
        // Track total moves for accuracy calculation
        this.totalMoves++
      },
      [GameEvent.MOVE_SUCCESS]: () => {
        // Track correct moves for accuracy calculation
        this.correctMoves++
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
    Timer,
  },
}
</script>
