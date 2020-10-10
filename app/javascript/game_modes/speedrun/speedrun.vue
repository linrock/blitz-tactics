<template lang="pug">
  aside.speedrun-sidebar
    .timers(:style="{ display: hasStarted ? '' : 'none' }")
      .current-run
        .timer.stopped 0:00.0
        .description {{ puzzleIdx }} of {{ numPuzzles }} solved

      .personal-best.invisible(style="display: none")
        .timer
        .description Personal best

      a.dark-button.view-puzzles.invisible(href="/speedrun/puzzles" style="display: none")
        | View puzzles

      a.blue-button.invisible(href="/speedrun" style="display: none")
        | Play again

    template(v-if="!hasStarted")
      .make-a-move Make a move to start the timer

</template>

<script lang="ts">
  import { speedrunCompleted } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe } from '@blitz/store'

  import SpeedrunComplete from './views/speedrun_complete'
  import Timer from './views/timer'

  const apiPath = `/speedrun/puzzles.json`

  export default {
    data() {
      return {
        hasStarted: false,
        numPuzzles: 0,
        puzzleIdx: 0,
      }
    },

    mounted() {
      new Timer
      new SpeedrunComplete

      let levelName: string

      subscribe({
        'config:init': data => levelName = data.level_name,

        'level:selected': name => {
          dispatch(`source:changed`, `${apiPath}?name=${name}`)
        },

        'timer:stopped': elapsedTimeMs => {
          const boardOverlayEl: HTMLElement = document.querySelector(`.board-modal-container`)
          boardOverlayEl.style.display = ``
          boardOverlayEl.classList.remove(`invisible`)
          speedrunCompleted(levelName, elapsedTimeMs).then(data => {
            dispatch(`speedrun:complete`, data)
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
    }
  }
</script>
