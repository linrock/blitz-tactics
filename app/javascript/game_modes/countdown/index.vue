<template lang="pug">
aside.countdown-under-board
  .timers(:style="{ display: (isStarted && !isEnded) ? '' : 'none'}")
    .current-countdown
      timer
      .description {{ nPuzzlesSolved }} puzzles solved

  .countdown-complete(v-if="isEnded")
    .score-container.your-score
      .label Your score
      .score {{ score }}

    .score-container.high-score
      .label High score
      .score {{ highScore }}

    a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
    a.blue-button(href="/countdown") Play again

  .make-a-move(v-if="!isStarted") Make a move to start the timer

</template>

<script lang="ts">
import { countdownCompleted } from '@blitz/api/requests'
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
      isEnded: false,
      nPuzzlesSolved: 0,
      score: 0,
      highScore: 0,
    }
  },

  mounted() {
    let levelName: string
    const commonSubscriptions = this.setupCommonSubscriptions()

    subscribe({
      ...commonSubscriptions,
      'config:init': data => levelName = data.level_name,
      'puzzles:status': ({ i }) => {
        this.nPuzzlesSolved = i + 1
      },
      'timer:stopped': () => {
        this.showBoardOverlay()
        countdownCompleted(levelName, this.nPuzzlesSolved).then(data => {
          const { score, best } = data
          this.score = score
          this.highScore = best
          this.isEnded = true
        })
        this.saveMistakesToStorage()
      },
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noCounter: true,
      noHint: true,
      source: '/countdown/puzzles.json',
    })
  },

  components: {
    Timer
  }
}
</script>
