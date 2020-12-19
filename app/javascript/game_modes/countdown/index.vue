<template lang="pug">
aside.countdown-sidebar
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

    a.blue-button(href="/countdown") Play again

  .make-a-move(v-if="!isStarted") Make a move to start the timer

</template>

<script lang="ts">
  import { countdownCompleted } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe, subscribeOnce } from '@blitz/store'

  import Timer from './timer.vue'

  import './style.sass'
  import './responsive.sass'

  export default {
    data() {
      return {
        isStarted: false,
        isEnded: false,
        nPuzzlesSolved: 0,
        score: 0,
        highScore: 0,
      }
    },

    mounted() {
      let levelName: string

      subscribe({
        'config:init': data => levelName = data.level_name,
        'puzzles:status': ({ i }) => {
          this.nPuzzlesSolved = i + 1
        },
        'timer:stopped': () => {
          // Cover the board with a dark transluscent overlay after the game ends
          const boardOverlayEl: HTMLElement = document.querySelector(`.board-modal-container`)
          boardOverlayEl.style.display = ``
          boardOverlayEl.classList.remove(`invisible`)
          dispatch(`timer:complete`, this.nPuzzlesSolved)
        },
        'timer:complete': score => {
          countdownCompleted(levelName, score).then(data => {
            const { score, best } = data
            this.score = score
            this.highScore = best
            this.isEnded = true
          })
        },
      })

      subscribeOnce('move:try', () => {
        this.isStarted = true;
      })

      new PuzzlePlayer({
        shuffle: false,
        loopPuzzles: false,
        noCounter: true,
        noHint: true,
        source: '/countdown/puzzles.json',
        useChessground: true,
      })
    },

    components: {
      Timer
    }
  }
</script>
