<template lang="pug">
aside.threes-sidebar
  .timers(:style="`display: ${(!hasFinished) ? '' : 'none'}`")
    .current-progress
      timer
      .n-remaining.n-lives(:class=`{ penalized: isLosingLife }`)
        | {{ numLives }} {{ numLives > 1 ? 'lives' : 'life left' }}
      .n-remaining.n-hints {{ numHints }} hints

  .make-a-move(v-if="!hasStarted")
    | Make a move to start the game

  .hints(v-if="hasStarted && !hasFinished")
    div(v-if="moveHint") Hint: {{ moveHint }}
    div(v-else-if="numHints > 0")
      a.dark-button(@click="viewHint") Use hint

  .current-score(v-if="hasStarted && !hasFinished")
    .label Score
    .score {{ numPuzzlesSolved }}

  // when the game has finished
  .threes-complete(v-if="hasFinished")
    .score-container.your-score
      .label Your score
      .score {{ yourScore }}

    .score-container.high-score
      .label Your high score today
      .score {{ highScore }}

    .puzzles-failed(v-if="puzzleIdsFailed.length > 0")
      div(v-for="puzzleId in puzzleIdsFailed")
        a(:href="`/p/${puzzleId}`" target="_blank")
          svg(viewBox="0 0 45 45")
            use(xlink:href="#x-mark" width="100%" height="100%")
          | Puzzle {{ puzzleId }}

    .score-container.recent-high-scores(v-if="highScores.length >= 3")
      .label Past 24 hours
      .list
        .high-score(v-for="[playerName, score] in highScores")
          .score {{ score }}
          .player-name {{ playerName }}

    a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
    a.blue-button(href="/threes") Play again

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
      isShowingHint: false,
      isLosingLife: false,
      ignoreNextPuzzleScore: false,
      moveHint: null,
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
      if (this.hasFinished) {
        return
      }
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
        this.moveHint = null
        this.currentPuzzleId = data.puzzle.id
        this.puzzleIdsSeen.push(this.currentPuzzleId)
      },
      'puzzle:hint': hint => {
        this.numHints -= 1
        const halfHint = Math.random() < 0.5 ? hint.slice(0, 2) : hint.slice(2, 4)
        this.moveHint = halfHint
      },
      'puzzles:status': ({ i }) => {
        // triggered when a puzzle gets loaded
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
        if (this.numLives <= 0) {
          return
        }
        this.numLives -= 1
        this.puzzleIdsFailed.push(this.currentPuzzleId)
        if (this.numLives > 0) {
          // move on to the next puzzle after a mistake
          this.ignoreNextPuzzleScore = true
          this.isLosingLife = true
          setTimeout(() => this.isLosingLife = false, 500)
          dispatch('puzzles:next')
        } else {
          // if not enough lives, the game is over
          gameOver()
        }
      },
      'move:try': () => {
        this.moveHint = null
      }
    })

    subscribeOnce(`move:try`, () => {
      this.hasStarted = true
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: '/threes/puzzles',
    })
  },

  methods: {
    viewHint() {
      console.log('give me a hint')
      dispatch('puzzle:get_hint')
    }
 },

  components: {
    Timer,
  },
}
</script>
