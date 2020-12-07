<template lang="pug">
aside.haste-sidebar
  .timers(:style="`display: ${(hasStarted && !hasFinished) ? '' : 'none'}`")
    .current-progress
      timer
      .n-solved {{ numPuzzlesSolved }} puzzles solved
      .n-hints {{ numHints }} hints
      .n-lives {{ numLives }} lives

  .haste-complete(v-if="hasFinished")
    .score-container.your-score
      .label Your score
      .score {{ yourScore }}

    .score-container.high-score
      .label Your high score today
      .score {{ highScore }}

    .puzzles-failed(v-if="puzzleIdsFailed.length > 0")
      div(v-for="puzzleId in puzzleIdsFailed")
        a(:href="`/p/${puzzleId}`" target="_blank") Puzzle {{ puzzleId }}

    .score-container.recent-high-scores(v-if="highScores.length >= 3")
      .label Past 24 hours
      .list
        .high-score(v-for="[playerName, score] in highScores")
          .score {{ score }}
          .player-name {{ playerName }}

    a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
    a.blue-button(href="/threes") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the game

</template>

<script lang="ts">
import { threesRoundCompleted } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import { dispatch, subscribe, subscribeOnce } from '@blitz/store'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  data() {
    return {
      hasStarted: false,
      hasFinished: false,
      ignoreNextPuzzleScore: false,
      numPuzzlesSolved: 0,
      numHints: 3,
      numLives: 3,
      yourScore: 0,
      highScore: 0,
      currentPuzzleId: 0,
      puzzleIdsSeen: [] as number[],
      puzzleIdsFailed: [] as number[],
      highScores: [] as [string, number][],
    }
  },

  computed: {
    viewPuzzlesLink(): string {
      return `/puzzles/${this.puzzleIdsSeen.join(',')}`
    }
  },

  mounted() {
    const gameOver = async () => {
      // Show an overlay over the board area after the round completes
      const el: HTMLElement = document.querySelector(`.board-modal-container`)
      el.style.display = ``
      el.classList.remove(`invisible`)
      // Notify the server that the round has finished. Show high scores
      const data = await threesRoundCompleted(this.numPuzzlesSolved)
      this.yourScore = data.score
      this.highScore = data.best
      this.highScores = data.high_scores
      this.hasFinished = true
      dispatch('timer:stop')
    }
    subscribe({
      'puzzle:loaded': data => {
        this.currentPuzzleId = data.puzzle.id
        this.puzzleIdsSeen.push(this.currentPuzzleId)
      },
      'puzzles:status': ({ i }) => {
        if (this.ignoreNextPuzzleScore) {
          this.ignoreNextPuzzleScore = false
        } else {
          this.numPuzzlesSolved += 1
        }
      },
      'timer:stopped': () => {
        gameOver();
      },
      'move:fail': () => {
        this.numLives -= 1
        this.puzzleIdsFailed.push(this.currentPuzzleId)
        if (this.numLives > 0) {
          // move on to the next puzzle after a mistake
          this.ignoreNextPuzzleScore = true
          dispatch('puzzles:next')
        } else {
          // if not enough lives, the game is over
          gameOver();
        }
      }
    })

    subscribeOnce(`move:try`, () => {
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
