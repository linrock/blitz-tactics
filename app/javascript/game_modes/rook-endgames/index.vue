<template lang="pug">
.rook-endgames-under-board.game-under-board
  .timers(:style="`display: ${(hasStarted && !hasFinished) ? '' : 'none'}`")
    .current-progress
      timer
      .n-solved {{ numPuzzlesSolved }} puzzles solved

  .rook-endgames-complete(v-if="hasFinished")
    .score-section
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

    .action-buttons
      a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
      a.blue-button(href="/rook-endgames") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { rookEndgamesRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { subscribe } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin],

  data() {
    return {
      numPuzzlesSolved: 0,
      yourScore: 0,
      highScore: 0,
      highScores: [] as [string, number][],
    }
  },

  mounted() {
    const commonSubscriptions = this.setupCommonSubscriptions()
    
    subscribe({
      ...commonSubscriptions,
      'puzzles:status': ({ i }) => {
        this.numPuzzlesSolved = i + 1
      },
      'puzzle:solved': (puzzle) => {
        // Track individual puzzle solve
        if (puzzle && puzzle.id) {
          trackSolvedPuzzle(puzzle.id, 'rook_endgames').catch(error => {
            console.error('Failed to track solved puzzle:', error)
          })
        }
      },
      'timer:stopped': async () => {
        this.showBoardOverlay()
        // Notify the server that the round has finished. Show high scores
        const data = await rookEndgamesRoundCompleted(this.numPuzzlesSolved)
        this.yourScore = data.score
        this.highScore = data.best
        this.highScores = data.high_scores
        this.hasFinished = true
        this.saveMistakesToStorage()
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: '/rook-endgames/puzzles',
    })
  },

  components: {
    Timer,
  },
}
</script>