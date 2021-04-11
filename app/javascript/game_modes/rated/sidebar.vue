<template lang="pug">
aside.rated-sidebar
  .current-status
    .your-rating
      .label Your rating
      .player-rating {{ playerRating }}
    .puzzles-seen
      .label Puzzles seen
      .n-puzzles {{ numPuzzlesSeen }}

  .moves-attempted(v-if="hasStarted")
    transition-group(name="player-move" tag="div")
      .move-attempt(v-for="move in playerMoves" :key="move.i" :class="move.type")
        svg(viewBox="0 0 45 45")
          use(:xlink:href="move.type === 'fail' ? '#x-mark' : '#check-mark'" width="100%" height="100%")
        .move-san {{ move.moveSan }}
    .moves-shadow

  .instructions(v-if="!hasStarted")
    ul
      li Solve puzzles quickly to gain more rating points
      li Click start or make a move to begin
    button.blue-button.start-button(@click="nextPuzzle") Start

  a.dark-button.recent-puzzles-btn(href="/rated/puzzles") Recent puzzles

</template>

<script lang="ts">
  import { dispatch, subscribe, subscribeOnce } from '@blitz/events'

  export default {
    data() {
      return {
        hasStarted: false,
        playerRating: 0,
        playerMoveIdx: 0,
        playerMoves: [],
        numPuzzlesSeen: 0,
      }
    },

    mounted() {
      const data = JSON.parse(document.querySelector('#rated-mode-data').textContent)
      console.dir(data)
      this.playerRating = data.playerRating
      this.numPuzzlesSeen = data.numPuzzlesSeen

      subscribeOnce(`puzzles:next`, () => {
        this.hasStarted = true
      })

      subscribe({
        'rated_puzzle:attempted': data => {
          this.playerRating = Math.round(data.rated_puzzle_attempt.post_user_rating)
          this.numPuzzlesSeen = data.user_rating.rated_puzzle_attempts_count
        },
        'move:make': (move, options = {}) => {
          if (!options.opponent) {
            console.log(JSON.stringify(move))
            this.addPlayerMove(move.san, 'success')
          }
        },
        'move:almost': move => this.addPlayerMove(move.san, 'almost'),
        'move:fail': move => this.addPlayerMove(move.san, 'fail')
      })
    },

    methods: {
      nextPuzzle() {
        dispatch('puzzles:next')
      },
      addPlayerMove(san: string, type: 'success' | 'almost' | 'fail') {
        this.playerMoves.unshift({
          i: this.playerMoveIdx,
          moveSan: san,
          type,
        })
        this.playerMoveIdx = this.playerMoveIdx + 1
      }
    },
  }
</script>

<style>
  .player-move-enter {
    opacity: 0;
  }
  .player-move-enter-to {
    opacity: 1;
  }
</style>