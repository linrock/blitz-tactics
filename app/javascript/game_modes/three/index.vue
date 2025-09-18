<template lang="pug">
aside.three-under-board.game-under-board
  .three-during-game(:style="`display: ${(!hasFinished) ? '' : 'none'}`")
    .timers
      timer
      .n-remaining.n-lives(:class=`{ penalized: isLosingLife }` style="margin-bottom: 0.5rem")
        | {{ numLives }} {{ numLives === 1 ? 'life left' : 'lives' }}
      .n-remaining.n-hints
        | {{ numHints }} {{ numHints === 1 ? 'hint' : 'hints' }}

      // shown during the game
      .hints(v-if="hasStarted && !hasFinished")
        div(v-if="moveHint") Hint: {{ moveHint }}
        div(v-else-if="numHints > 0")
          a.dark-button(@click="viewHint") Use hint

    .right-side
      // shown before the game starts
      .make-a-move(v-if="!hasStarted")
        | Make a move to start the game

      .current-score(v-if="hasStarted && !hasFinished")
        .label Score
        .score(:class=`{ rewarded: isGainingScore }`) {{ numPuzzlesSolved }}

  // shown when the game has finished
  .three-complete(v-if="hasFinished")
    .three-complete-section.scores
      .score-container.your-score
        .label Your score
        .score {{ yourScore }}

      .score-container.high-score
        .label Your high score today
        .score {{ highScore }}

    .three-complete-section.actions
      .action-buttons
        a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
        a.blue-button(href="/three") Play again

      .three-complete-section.missed
        .puzzles-failed(v-if="puzzleIdsFailed.length > 0")
          div(v-for="puzzleId in puzzleIdsFailed")
            a(:href="`/p/${puzzleId}`" target="_blank")
              svg(viewBox="0 0 45 45")
                use(xlink:href="#x-mark" width="100%" height="100%")
              | Puzzle {{ puzzleId }}

</template>

<script lang="ts">
import { threeRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { dispatch, subscribe } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin],

  data() {
    return {
      isShowingHint: false,
      isLosingLife: false,
      isGainingScore: false,
      ignoreNextPuzzleScore: false,
      moveHint: null,
      numPuzzlesSolved: 0,
      solvedPuzzleIds: [] as string[],
      numHints: 3,
      numLives: 3,
      yourScore: 0,
      highScore: 0,
      puzzleIdsFailed: [] as number[],
      highScores: [] as [string, number][],
    }
  },

  mounted() {
    const gameOver = async () => {
      if (this.hasFinished) {
        return
      }
      this.showBoardOverlay()
      // Notify the server that the round has finished. Show high scores
      const data = await threeRoundCompleted(this.numPuzzlesSolved, this.solvedPuzzleIds)
      this.yourScore = data.score
      this.highScore = data.best
      this.highScores = data.high_scores
      this.hasFinished = true
      dispatch('timer:stop')
    }

    const commonSubscriptions = this.setupCommonSubscriptions()
    
    subscribe({
      ...commonSubscriptions,
      'puzzle:loaded': data => {
        this.moveHint = null
        this.trackPuzzleLoaded(data.puzzle.id)
      },
      'puzzle:hint': hint => {
        this.numHints -= 1
        const halfHint = Math.random() < 0.5 ? hint.slice(0, 2) : hint.slice(2, 4)
        this.moveHint = halfHint
        dispatch('shape:draw', halfHint)
      },
      'puzzles:status': ({ i }) => {
        // triggered when a puzzle gets loaded onto the board
        if (this.ignoreNextPuzzleScore) {
          // happens after a mistake
          this.ignoreNextPuzzleScore = false
        } else {
          // happens after solving a puzzle
          this.numPuzzlesSolved += 1
          this.isGainingScore = true
          setTimeout(() => this.isGainingScore = false, 300)
        }
      },
      'puzzle:solved': async (puzzle) => {
        if (puzzle && puzzle.id) {
          this.solvedPuzzleIds.push(puzzle.id)
          
          // Send puzzle ID to server immediately for real-time tracking
          try {
            await this.trackSolvedPuzzle(puzzle.id)
          } catch (error) {
            console.error('Failed to track solved puzzle:', error)
          }
        }
      },
      'timer:stopped': () => {
        gameOver();
      },
      'move:success': () => {
        this.hasStarted = true
      },
      'move:fail': () => {
        if (!this.hasStarted) {
          this.hasStarted = true
        }
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
        if (!this.hasStarted) {
          this.hasStarted = true
        }
        commonSubscriptions['move:try']()
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: '/three/puzzles',
    })
  },

  methods: {
    viewHint() {
      dispatch('puzzle:get_hint')
    },

    async trackSolvedPuzzle(puzzleId) {
      // Use the simplified puzzle tracking system
      try {
        return await trackSolvedPuzzle(puzzleId)
      } catch (error) {
        console.error('Failed to track solved puzzle:', error)
        throw error
      }
    }
  },

  components: {
    Timer,
  }
}
</script>
