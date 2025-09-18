<template lang="pug">
.haste-under-board.game-under-board
  .timers(:style="`display: ${(hasStarted && !hasFinished) ? '' : 'none'}`")
    .current-progress
      timer
      .n-solved {{ numPuzzlesSolved }} puzzles solved

  .haste-complete(v-if="hasFinished")
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
      a.blue-button(href="/haste") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { hasteRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
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
      solvedPuzzleIds: [] as string[],
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
      'puzzle:solved': async (puzzle) => {
        console.log('Puzzle solved:', puzzle)
        if (puzzle && puzzle.id) {
          this.solvedPuzzleIds.push(puzzle.id)
          console.log('Added puzzle ID:', puzzle.id, 'Total solved:', this.solvedPuzzleIds.length)
          
          // Send puzzle ID to server immediately for real-time tracking
          try {
            await this.trackSolvedPuzzle(puzzle.id)
          } catch (error) {
            console.error('Failed to track solved puzzle:', error)
          }
        } else {
          console.log('No puzzle ID found in puzzle:', puzzle)
        }
      },
      'timer:stopped': async () => {
        this.showBoardOverlay()
        console.log('Round completed. Sending puzzle IDs:', this.solvedPuzzleIds)
        // Notify the server that the round has finished. Show high scores
        const data = await hasteRoundCompleted(this.numPuzzlesSolved, this.solvedPuzzleIds)
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
      source: '/haste/puzzles',
    })
  },

  components: {
    Timer,
  },

  methods: {
    async trackSolvedPuzzle(puzzleId) {
      // Track puzzle with game mode
      try {
        return await trackSolvedPuzzle(puzzleId, 'haste')
      } catch (error) {
        console.error('Failed to track solved puzzle:', error)
        throw error
      }
    }
  }
}
</script>
