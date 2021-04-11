<template lang="pug">
aside.infinity-sidebar
  .difficulties
    .sidebar-label Difficulty
    template(v-for="difficulty in difficulties")
      .difficulty(
        :class="[difficulty, { selected: currentDifficulty === difficulty }]"
        @click="chooseDifficulty(difficulty)"
      ) {{ difficulty }}

  .stats(:class="{ invisible: !nPuzzlesSolved }")
    .sidebar-label You have solved
    .n-puzzles {{ nPuzzlesSolved }} puzzles

  .recent-puzzles
    a.dark-button(href="/infinity/puzzles") Recent puzzles

  .no-more-left(v-if="noMoreLeft")
    | You did it! You solved all the puzzles in this level.
    | Chooose another difficulty to continue.
  
</template>

<script lang="ts">
  import { infinityPuzzleSolved } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe } from '@blitz/events'

  import { InfinityPuzzleDifficulty } from './index'

  const apiPath = `/infinity/puzzles.json`
  const fetchThreshold = 5 // fetch more puzzles when this # puzzles remain
  const difficulties = ['easy', 'medium', 'hard', 'insane'] as InfinityPuzzleDifficulty[]

  export default {
    data() {
      return {
        nPuzzlesSolved: 0,
        noMoreLeft: false,
        currentDifficulty: 'easy' as InfinityPuzzleDifficulty,
        difficulties,
      }
    },

    methods: {
      chooseDifficulty(difficulty: InfinityPuzzleDifficulty) {
        if (difficulty !== this.currentDifficulty) {
          this.currentDifficulty = difficulty
          dispatch(`source:changed`, `${apiPath}?difficulty=${difficulty}`)
        }
        this.noMoreLeft = false
      },
    },

    mounted() {
      subscribe({
        'config:init': data => {
          this.currentDifficulty = data.difficulty
          this.nPuzzlesSolved = data.num_solved
        },

        'puzzle:solved': puzzle => {
          const puzzleData = {
            puzzle_id: puzzle.id,
            difficulty: this.currentDifficulty
          }
          infinityPuzzleSolved(puzzleData).then(data => {
            if (data.n) {
              this.nPuzzlesSolved = data.n 
            } else {
              this.nPuzzlesSolved = this.nPuzzlesSolved + 1
            }
          })
        },

        'puzzles:status': status => {
          const { i, n, lastPuzzleId } = status
          if (i + fetchThreshold > n) {
            dispatch(
              `source:changed:add`,
              `${apiPath}?difficulty=${this.currentDifficulty}&after_puzzle_id=${lastPuzzleId}`,
            )
          }
        },

        'puzzles:complete': () => {
          this.noMoreLeft = true
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
