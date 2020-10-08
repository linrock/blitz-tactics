<template>
  <aside class="countdown-sidebar" ref="sidebar">
    <div class="timers" :style="{ display: (isStarted && !isEnded) ? '' : 'none'}">
      <div class="current-countdown">
        <timer />
        <div class="description">{{ nPuzzlesSolved }} puzzles solved</div>
      </div>
    </div>

    <div class="countdown-complete" v-if="isEnded">
      <div class="score-container your-score">
        <div class="label">Your score</div>
        <div class="score">{{ score }}</div>
      </div>

      <div class="score-container high-score">
        <div class="label">High score</div>
        <div class="score">{{ highScore }}</div>
      </div>

      <a href="/countdown" class="blue-button">Play again</a>
    </div>

    <div class="make-a-move" v-if="!isStarted">
      Make a move to start the timer
    </div>
  </aside>
</template>

<script>
  import { countdownCompleted } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe, subscribeOnce } from '@blitz/store'

  import Timer from './timer'

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
      console.log('mounted!');

      let levelName

      subscribe({
        'config:init': data => levelName = data.level_name,
        'puzzles:status': ({ i }) => {
          this.nPuzzlesSolved = i + 1
        },
        'timer:stopped': () => {
          // Cover the board with a dark transluscent overlay after the game ends
          const boardOverlayEl = document.querySelector(`.board-modal-container`)
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

      subscribeOnce(`move:try`, () => {
        this.isStarted = true;
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
