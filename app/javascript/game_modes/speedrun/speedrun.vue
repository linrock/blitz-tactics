<template lang="pug">
  aside.speedrun-sidebar
    .timers(style="display: none")
      .current-run
        .timer.stopped 0:00.0
        .description

      .personal-best.invisible(style="display: none")
        .timer
        .description Personal best

      a.dark-button.view-puzzles.invisible(href="/speedrun/puzzles" style="display: none")
        | View puzzles

      a.blue-button.invisible(href="/speedrun" style="display: none")
        | Play again

    .make-a-move Make a move to start the timer

</template>

<script lang="ts">
  import { speedrunCompleted } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe } from '@blitz/store'

  import Modal from './views/modal'
  import Progress from './views/progress'
  import Sidebar from './views/sidebar'
  import SpeedrunComplete from './views/speedrun_complete'
  import Timer from './views/timer'

  const apiPath = `/speedrun/puzzles.json`

  export default {
    mounted() {
      new Sidebar
      new Timer
      new Modal
      new Progress
      new SpeedrunComplete

      let levelName: string

      subscribe({
        'config:init': data => levelName = data.level_name,

        'level:selected': name => {
          dispatch(`source:changed`, `${apiPath}?name=${name}`)
        },

        'timer:stopped': elapsedTimeMs => {
          speedrunCompleted(levelName, elapsedTimeMs).then(data => {
            dispatch(`speedrun:complete`, data)
          })
        }
      })

      new PuzzlePlayer({
        shuffle: false,
        loopPuzzles: false,
        source: apiPath,
      })
    }
  }
</script>
