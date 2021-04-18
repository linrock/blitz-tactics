<template lang="pug">

</template>

<script>
  import PuzzlePlayer from '@blitz/components/puzzle_player'

  import "./style.sass"

  export default {
    mounted() {
      new PuzzlePlayer({
        shuffle: false,
        loopPuzzles: false,
        noCounter: true,
        noHint: true,
        source: '/countdown/puzzles.json',
      })
    }
  }
</script>
