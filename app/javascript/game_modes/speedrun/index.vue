<template lang="pug">
aside.speedrun-under-board
  .timers(:style="{ display: hasStarted ? '' : 'none' }")
    .current-run
      timer
      .description {{ puzzleIdx }} of {{ numPuzzles }} solved

    template(v-if="hasCompleted")
      .personal-best
        .timer {{ formattedBestTime }}
        .description Personal best
      a.dark-button.view-puzzles(href="/speedrun/puzzles") View puzzles
      a.blue-button(href="/speedrun") Play again

  template(v-if="!hasStarted")
    .make-a-move Make a move to start the timer

</template>

<script lang="ts">
  import { speedrunCompleted } from '@blitz/api/requests'
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
      }
    },

    computed: {
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
        'move:try': () => {
          // Handle hasStarted for speedrun mode
          if (!this.hasStarted) {
            this.hasStarted = true
          }
        },
        
        'timer:stopped': elapsedTimeMs => {
          const boardOverlayEl: HTMLElement = document.querySelector(`.board-modal-container`)
          boardOverlayEl.style.display = ``
          boardOverlayEl.classList.remove(`invisible`)
          speedrunCompleted(this.levelName, elapsedTimeMs).then(data => {
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
