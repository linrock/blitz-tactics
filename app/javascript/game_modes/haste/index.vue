<template lang="pug">
aside.haste-sidebar
  .timers(:style="`display: ${(hasStarted && !hasFinished) ? '' : 'none'}`")
    .current-progress
      timer
      .n-solved {{ numPuzzlesSolved }} puzzles solved

  .haste-complete(v-if="hasFinished")
    .score-container.your-score
      .label Your score
      .score {{ yourScore }}

    .score-container.high-score
      .label Your high score today
      .score {{ highScore }}

    .score-container.recent-high-scores(v-if="highScores.length >= 3")
      .label Past 24 hours
      .list
        .high-score(v-for="[playerName, score] in highScores")
          .score {{ score }}
          .player-name {{ playerName }}

    a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
    a.blue-button(href="/haste") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { hasteRoundCompleted } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import store from '@blitz/local_storage'
import { dispatch, subscribe, subscribeOnce } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

const puzzleIdsMistakes: Record<number, string[]> = {}

export default {
  data() {
    return {
      hasStarted: false,
      hasFinished: false,
      numPuzzlesSolved: 0,
      currentPuzzleId: 0,
      puzzleIdsSeen: [] as number[],
      yourScore: 0,
      highScore: 0,
      highScores: [] as [string, number][],
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
        // Notify the server that the round has finished. Show high scores
        const data = await hasteRoundCompleted(this.numPuzzlesSolved)
        this.yourScore = data.score
        this.highScore = data.best
        this.highScores = data.high_scores
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

    subscribeOnce('move:try', () => {
      this.hasStarted = true
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: '/haste/puzzles',
    })
  },

  components: {
    Timer,
  },
}
</script>
