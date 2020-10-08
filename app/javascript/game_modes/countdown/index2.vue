<template>
  <aside class="countdown-sidebar" ref="sidebar">
    <div class="timers" :style="{ display: started ? '' : 'none'}">
      <div class="current-countdown">
        <div class="timer stopped" ref="timer">5:00</div>
        <div class="description">0 puzzles solved</div>
      </div>
    </div>

    <div class="countdown-complete invisible" style="display: none">
      <div class="score-container your-score">
        <div class="label">Your score</div>
        <div class="score"></div>
      </div>

      <div class="score-container high-score">
        <div class="label">High score</div>
        <div class="score"></div>
      </div>

      <a href="/countdown" class="blue-button">Play again</a>
    </div>

    <div class="make-a-move" v-if="!started">
      Make a move to start the timer
    </div>
  </aside>
</template>

<script>
  import { countdownCompleted } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe, subscribeOnce } from '@blitz/store'

  import Timer from './views/timer'
  import Progress from './views/progress'
  import Modal from './views/modal'
  import CountdownComplete from './views/countdown_complete'

  export default {
    data() {
      return {
        started: false,
      }
    },
    mounted() {
      console.log('mounted!');

      new Timer(this.$refs.timer)
      new Progress
      new Modal
      new CountdownComplete

      let levelName

      subscribe({
        'config:init': data => levelName = data.level_name,

        'timer:complete': score => {
          countdownCompleted(levelName, score).then(data => {
            dispatch(`countdown:complete`, data)
          })
        }
      })

      subscribeOnce(`move:try`, () => {
        this.started = true;
      })

      new PuzzlePlayer({
        shuffle: false,
        loopPuzzles: false,
        noCounter: true,
        noHint: true,
        source: '/countdown/puzzles.json',
      })
    }
  }
</script>

<style scoped>
  body {
    background: green;
  }

</style>
