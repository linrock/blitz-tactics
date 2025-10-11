<template lang="pug">
.mate-in-one-under-board.game-under-board
  .timers(:style="`display: ${(hasStarted && !hasFinished) ? '' : 'none'}`")
    .current-progress
      timer
      .n-solved {{ numPuzzlesSolved }} puzzles solved

  .mate-in-one-complete(v-if="hasFinished")
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
      a.blue-button(href="/mate-in-one") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { mateInOneRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import PuzzleTrackingMixin from '@blitz/components/puzzle_tracking_mixin'
import { subscribe, GameEvent } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin, PuzzleTrackingMixin],

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
    const puzzleTracking = this.setupPuzzleTrackingSubscriptions('mate_in_one', trackSolvedPuzzle)
    
    subscribe({
      ...commonSubscriptions,
      ...puzzleTracking,
      [GameEvent.PUZZLES_STATUS]: ({ i }) => {
        this.numPuzzlesSolved = i + 1
      },
      [GameEvent.TIMER_STOPPED]: async () => {
        this.showBoardOverlay()
        // Calculate elapsed time in milliseconds
        const elapsedTimeMs = this.initialTimeMs - this.timeLeftMilliseconds
        // Notify the server that the round has finished. Show high scores
        const data = await mateInOneRoundCompleted(this.numPuzzlesSolved, elapsedTimeMs)
        this.yourScore = data.score
        this.highScore = data.best
        this.highScores = data.high_scores
        this.hasFinished = true
        this.saveMistakesToStorage()
        
        // Add unsolved puzzle and show section
        this.addUnsolvedPuzzle()
        if (this.playedPuzzles.length > 0) {
          this.showPlayedPuzzlesSection()
        }
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: '/mate-in-one/puzzles',
    })
  },

  components: {
    Timer,
  },
}
</script>
