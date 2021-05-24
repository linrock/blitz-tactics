<template lang="pug">
aside.puzzle-set-sidebar
  .timers(:style="`display: ${(hasStarted && !hasFinished) ? '' : 'none'}`")
    .current-progress
      timer
      .n-solved {{ numPuzzlesSolved }} puzzles solved

  .puzzle-set-complete(v-if="hasFinished")
    .score-container.your-score
      .label Your score
      .score {{ yourScore }}

    a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
    a.blue-button(:href="puzzleSetUrl") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { subscribe } from '@blitz/events'
import store from '@blitz/local_storage'

import Timer from '../../game_modes/haste/timer.vue'

import './style.sass'
import './responsive.sass'

const puzzleIdsMistakes: Record<number, string[]> = {}

export default {
  data() {
    return {
      hasStarted: true,
      hasFinished: false,
      puzzleSetUrl: window.location.pathname,
      numPuzzlesSolved: 0,
      currentPuzzleId: 0,
      puzzleIdsSeen: [] as number[],
      yourScore: 0,
    }
  },

  computed: {
    viewPuzzlesLink() {
      return `/puzzles/${this.puzzleIdsSeen.join(',')}`
    }
  },

  mounted() {
    subscribe({
      'puzzle:loaded': data => {
        this.currentPuzzleId = data.puzzle.id
        this.puzzleIdsSeen.push(this.currentPuzzleId)
      },
      'puzzles:status': ({ i }) => {
        this.numPuzzlesSolved = i + 1
      },
      'timer:stopped': async () => {
        // Show an overlay over the board area after the round completes
        const el: HTMLElement = document.querySelector(`.board-modal-container`)
        el.style.display = ``
        el.classList.remove(`invisible`)
        this.yourScore = this.numPuzzlesSolved
        this.hasFinished = true
        // Store the player's mistakes in case they want to view these later
        // Expires from local storage after 1 hour
        store.set(this.viewPuzzlesLink, puzzleIdsMistakes, new Date().getTime() + 86400 * 1000)
      },
      'move:fail': (move) => {
        console.log(`mistake! - ${this.currentPuzzleId} - ${move.san}`)
        if (!puzzleIdsMistakes[this.currentPuzzleId]) {
          puzzleIdsMistakes[this.currentPuzzleId] = []
        }
        puzzleIdsMistakes[this.currentPuzzleId].push(move.san)
      }
    })
  },

  components: {
    Timer,
  },
}

</script>
