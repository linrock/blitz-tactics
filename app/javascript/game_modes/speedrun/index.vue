<template lang="pug">
aside.speedrun-under-board.game-under-board
  .timers(:style="{ display: hasStarted && !hasCompleted ? '' : 'none' }")
    .current-run
      timer
      .description {{ puzzleIdx }} of {{ numPuzzles }} solved

  .speedrun-complete(v-if="hasCompleted")
    .timers-section
      .timer-container.your-time
        .label Your time
        .timer {{ formattedYourTime }}

      .timer-container.personal-best
        .label Personal best
        .timer {{ formattedBestTime }}

    .action-buttons
      a.dark-button.view-puzzles(href="/speedrun/puzzles") View puzzles
      a.blue-button(href="/speedrun") Play again

  template(v-if="!hasStarted")
    .make-a-move Make a move to start the timer

</template>

<script lang="ts">
  import { speedrunCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import GameModeMixin from '@blitz/components/game_mode_mixin'
  import { subscribe } from '@blitz/events'
  import { formattedTime } from '@blitz/utils'

  import Timer from './timer.vue'

  import './style.sass'
  import './responsive.sass'

  const apiPath = `/speedrun/puzzles.json`

  export default {
    mixins: [GameModeMixin],

    data() {
      return {
        hasCompleted: false,
        lebelName: null,
        numPuzzles: 0,
        puzzleIdx: 0,
        bestTime: 0,
        yourTime: 0,
      }
    },

    computed: {
      formattedYourTime(): string {
        return formattedTime(parseInt(this.yourTime as any, 0))
      },
      formattedBestTime(): string {
        return formattedTime(parseInt(this.bestTime, 0))
      }
    },

    mounted() {
      const commonSubscriptions = this.setupCommonSubscriptions()

      // Subscribe to common events first
      subscribe(commonSubscriptions)
      
      // Then subscribe to speedrun-specific events
      subscribe({
        'config:init': data => {
          this.levelName = data.level_name
        },

        'move:try': () => {
          // Handle hasStarted for speedrun mode
          if (!this.hasStarted) {
            this.hasStarted = true
          }
        },

        'puzzle:solved': (puzzle) => {
          // Track individual puzzle solve
          if (puzzle && puzzle.id) {
            trackSolvedPuzzle(puzzle.id).catch(error => {
              console.error('Failed to track solved puzzle:', error)
            })
          }
        },
        
        'timer:stopped': elapsedTimeMs => {
          console.log('timer:stopped', elapsedTimeMs)
          const boardOverlayEl: HTMLElement = document.querySelector(`.board-modal-container`)
          boardOverlayEl.style.display = ``
          boardOverlayEl.classList.remove(`invisible`)
          this.yourTime = elapsedTimeMs
          speedrunCompleted(this.levelName, elapsedTimeMs).then(data => {
            console.log('speedrun completed!')
            this.bestTime = data.best
            this.hasCompleted = true
          })
        },

        'puzzles:fetched': puzzles => {
          this.puzzleIdx = 0
          this.numPuzzles = puzzles.length
        },

        'puzzles:status': ({ i , n }) => {
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
    }
  }
</script>
