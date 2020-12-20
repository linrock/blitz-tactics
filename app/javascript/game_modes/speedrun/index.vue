<template lang="pug">
aside.speedrun-sidebar
  .timers(:style="{ display: hasStarted ? '' : 'none' }")
    .current-run
      timer
      .description {{ puzzleIdx }} of {{ numPuzzles }} solved

    template(v-if="hasCompleted")
      .personal-best
        .timer {{ formattedBestTime }}
        .description Personal best
      a.dark-button.view-puzzles(href="/speedrun/puzzles") View puzzles
      a.blue-button.invisible(href="/speedrun") Play again

  template(v-if="!hasStarted")
    .make-a-move Make a move to start the timer

</template>

<script lang="ts">
  import { speedrunCompleted } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe } from '@blitz/events'
  import { formattedTime } from '@blitz/utils'

  import Timer from './timer.vue'

  import './style.sass'
  import './responsive.sass'

  const apiPath = `/speedrun/puzzles.json`

  export default {
    data() {
      return {
        hasStarted: false,
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
      subscribe({
        'config:init': data => this.levelName = data.level_name,

        'timer:stopped': elapsedTimeMs => {
          const boardOverlayEl: HTMLElement = document.querySelector(`.board-modal-container`)
          boardOverlayEl.style.display = ``
          boardOverlayEl.classList.remove(`invisible`)
          speedrunCompleted(this.levelName, elapsedTimeMs).then(data => {
            this.bestTime = data.best
            this.hasCompleted = true
          })
        },

        'move:try': () => {
          this.hasStarted = true
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
