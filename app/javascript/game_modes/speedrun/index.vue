<template lang="pug">
aside.speedrun-under-board.game-under-board
  .timers(:style="{ display: hasStarted && !hasCompleted ? '' : 'none' }")
    .current-run
      timer
      .description {{ puzzleIdx }} of {{ numPuzzles }} solved

  .speedrun-complete(v-if="hasCompleted")
    .timers-section
      .timer-container.accuracy(:class="{ 'perfect-accuracy': isPerfectAccuracy }")
        .label Accuracy
        .timer {{ accuracyPercentage }}

      .timer-container.your-time
        .label Your time
        .timer {{ formattedYourTime }}

      .timer-container.personal-best
        .label Personal best
        .timer {{ formattedBestTime }}

    .action-buttons
      a.blue-button(href="/speedrun") Play again

  template(v-if="!hasStarted")
    .make-a-move Make a move to start the timer

</template>

<script lang="ts">
  import { speedrunCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import GameModeMixin from '@blitz/components/game_mode_mixin'
  import PuzzleTrackingMixin from '@blitz/components/puzzle_tracking_mixin'
  import { subscribe, GameEvent } from '@blitz/events'
  import { formattedTime } from '@blitz/utils'

  import Timer from './timer.vue'

  import './style.sass'
  import './responsive.sass'

  const apiPath = `/speedrun/puzzles.json`

  export default {
    mixins: [GameModeMixin, PuzzleTrackingMixin],

    data() {
      return {
        hasCompleted: false,
        lebelName: null,
        numPuzzles: 0,
        puzzleIdx: 0,
        bestTime: 0,
        yourTime: 0,
        totalMoves: 0,
        correctMoves: 0,
      }
    },

    computed: {
      formattedYourTime(): string {
        return formattedTime(parseInt(this.yourTime as any, 0))
      },
      formattedBestTime(): string {
        return formattedTime(parseInt(this.bestTime, 0))
      },
      accuracyPercentage(): string {
        if (this.totalMoves === 0) return '0%'
        const percentage = Math.round((this.correctMoves / this.totalMoves) * 100)
        return `${percentage}%`
      },
      isPerfectAccuracy(): boolean {
        if (this.totalMoves === 0) return false
        const percentage = Math.round((this.correctMoves / this.totalMoves) * 100)
        return percentage === 100
      }
    },

    mounted() {
      const commonSubscriptions = this.setupCommonSubscriptions()
      const puzzleTracking = this.setupPuzzleTrackingSubscriptions('speedrun', trackSolvedPuzzle)

      // Subscribe to common events first
      subscribe(commonSubscriptions)
      
      // Then subscribe to speedrun-specific events
      subscribe({
        ...puzzleTracking,
        [GameEvent.CONFIG_INIT]: data => {
          this.levelName = data.level_name
        },

        [GameEvent.MOVE_TRY]: () => {
          // Handle hasStarted for speedrun mode
          if (!this.hasStarted) {
            this.hasStarted = true
          }
          // Track total moves
          this.totalMoves++
        },

        [GameEvent.MOVE_SUCCESS]: () => {
          // Track correct moves
          this.correctMoves++
        },
        
        [GameEvent.TIMER_STOPPED]: elapsedTimeMs => {
          console.log('timer:stopped', elapsedTimeMs)
          const boardOverlayEl: HTMLElement = document.querySelector(`.board-modal-container`)
          boardOverlayEl.style.display = ``
          boardOverlayEl.classList.remove(`invisible`)
          this.yourTime = elapsedTimeMs
          
          // Note: In speedrun mode, the game only ends with a successful puzzle solve,
          // so the current puzzle is already added to playedPuzzles in the puzzle:solved handler
          
          speedrunCompleted(this.levelName, elapsedTimeMs).then(data => {
            console.log('speedrun completed!')
            this.bestTime = data.best
            this.hasCompleted = true
            
            // Show the played puzzles section if there are any
            if (this.playedPuzzles.length > 0) {
              this.showPlayedPuzzlesSection()
            }
          })
        },

        [GameEvent.PUZZLES_FETCHED]: puzzles => {
          this.puzzleIdx = 0
          this.numPuzzles = puzzles.length
        },

        [GameEvent.PUZZLES_STATUS]: ({ i , n }) => {
          this.puzzleIdx = i + 1
          this.numPuzzles = n
        },
      })

      new PuzzlePlayer({
        shuffle: false,
        loopPuzzles: false,
        source: apiPath,
      })
    },

    components: {
      Timer,
    },
  }
</script>
