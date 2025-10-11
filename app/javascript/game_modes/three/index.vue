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

    .score-container.recent-high-scores(v-if="highScores.length >= 3")
      .label Past 24 hours
      .list
        .high-score(v-for="[playerName, score] in highScores")
          .score {{ score }}
          .player-name {{ playerName }}

    .three-complete-section.actions
      .action-buttons
        a.blue-button(href="/three") Play again


</template>

<script lang="ts">
import { threeRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import PuzzleTrackingMixin from '@blitz/components/puzzle_tracking_mixin'
import { dispatch, subscribe, GameEvent } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin, PuzzleTrackingMixin],

  data() {
    return {
      isShowingHint: false,
      isLosingLife: false,
      isGainingScore: false,
      ignoreNextPuzzleScore: false,
      moveHint: null,
      numPuzzlesSolved: 0,
      numHints: 3,
      numLives: 3,
      yourScore: 0,
      highScore: 0,
      puzzleIdsFailed: [] as number[],
      failedPuzzles: [] as any[],
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
      dispatch(GameEvent.TIMER_STOP)
      
      // Add the current unsolved puzzle to the list if there is one and it hasn't been added already
      if (this.currentPuzzle) {
        const alreadyAdded = this.playedPuzzles.some(p => p.puzzle?.id === this.currentPuzzle.id)
        if (!alreadyAdded) {
          this.addUnsolvedPuzzle()
        } else {
          console.log('Current puzzle already in played list, skipping')
        }
      }
      
      // Show the played puzzles section if there are any
      if (this.playedPuzzles.length > 0) {
        this.showPlayedPuzzlesSection('missed-puzzles-section')
      }
    }

    const commonSubscriptions = this.setupCommonSubscriptions()
    const puzzleTracking = this.setupPuzzleTrackingSubscriptions('three', trackSolvedPuzzle)
    
    subscribe({
      ...commonSubscriptions,
      ...puzzleTracking,
      [GameEvent.PUZZLE_LOADED]: data => {
        this.moveHint = null
        this.trackPuzzleLoaded(data.puzzle.id)
        // Store current puzzle data for failed puzzle tracking
        this.currentPuzzle = data.puzzle
        this.currentPuzzleData = data
        this.currentPuzzleStartTime = Date.now()
        this.currentPuzzleMistakes = 0 // Reset mistakes for new puzzle
        console.log('Puzzle loaded:', data.puzzle.id, 'Start time:', this.currentPuzzleStartTime)
      },
      [GameEvent.PUZZLE_HINT]: hint => {
        this.numHints -= 1
        const halfHint = Math.random() < 0.5 ? hint.slice(0, 2) : hint.slice(2, 4)
        this.moveHint = halfHint
        dispatch(GameEvent.SHAPE_DRAW, halfHint)
      },
      [GameEvent.PUZZLES_STATUS]: ({ i }) => {
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
      [GameEvent.TIMER_STOPPED]: () => {
        gameOver();
      },
      [GameEvent.MOVE_SUCCESS]: () => {
        this.hasStarted = true
      },
      [GameEvent.MOVE_FAIL]: () => {
        console.log('Move failed - current puzzle:', this.currentPuzzle)
        console.log('Move failed - current puzzle data:', this.currentPuzzleData)
        
        // Track mistakes for current puzzle
        this.currentPuzzleMistakes++
        console.log('Mistake made on puzzle:', this.currentPuzzle?.id, 'Total mistakes:', this.currentPuzzleMistakes)
        
        if (!this.hasStarted) {
          this.hasStarted = true
        }
        if (this.numLives <= 0) {
          console.log('No lives left, not adding to failed puzzles')
          return
        }
        this.numLives -= 1
        this.puzzleIdsFailed.push(this.currentPuzzleId)
        
        // Calculate time spent on failed puzzle
        const endTime = Date.now()
        const solveTimeMs = this.currentPuzzleStartTime ? endTime - this.currentPuzzleStartTime : 0
        const solveTimeSeconds = Math.round(solveTimeMs / 100) / 10 // Round to 1 decimal place
        
        // Store the full puzzle data for the failed puzzle with timing and mistakes
        if (this.currentPuzzle) {
          this.playedPuzzles.push({
            puzzle: this.currentPuzzle,
            puzzle_data: this.currentPuzzleData,
            solveTime: solveTimeSeconds,
            mistakes: this.currentPuzzleMistakes,
            puzzleNumber: null, // No number for failed puzzles
            solved: false
          })
          console.log('Added failed puzzle:', this.currentPuzzle.id, 'Time:', solveTimeSeconds + 's', 'Mistakes:', this.currentPuzzleMistakes, 'Total played:', this.playedPuzzles.length)
        } else {
          console.log('No current puzzle available to add to failed puzzles')
        }
        
        if (this.numLives > 0) {
          // move on to the next puzzle after a mistake
          this.ignoreNextPuzzleScore = true
          this.isLosingLife = true
          setTimeout(() => this.isLosingLife = false, 500)
          dispatch(GameEvent.PUZZLES_NEXT)
        } else {
          // if not enough lives, the game is over
          gameOver()
        }
      },
      [GameEvent.MOVE_TRY]: () => {
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
      dispatch(GameEvent.PUZZLE_GET_HINT)
    },
  },

  components: {
    Timer,
  },
}
</script>
