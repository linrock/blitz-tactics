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

    a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
    a.blue-button(href="/countdown") Play again

  .make-a-move(v-if="!isStarted") Make a move to start the timer

</template>

<script lang="ts">
  import { countdownCompleted } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe, subscribeOnce } from '@blitz/events'
  import store from '@blitz/local_storage'

  import Timer from './timer.vue'

  import './style.sass'
  import './responsive.sass'

  const puzzleIdsMistakes: Record<number, string[]> = {}

  export default {
    data() {
      return {
        isStarted: false,
        isEnded: false,
        nPuzzlesSolved: 0,
        currentPuzzleId: 0,
        puzzleIdsSeen: [] as number[],
        score: 0,
        highScore: 0,
      }
    },

    computed: {
      viewPuzzlesLink(): string {
        return `/puzzles/${this.puzzleIdsSeen.join(',')}`
      },
    },

    mounted() {
      let levelName: string

      subscribe({
        'config:init': data => levelName = data.level_name,
        'puzzle:loaded': data => {
          this.currentPuzzleId = data.puzzle.id
          this.puzzleIdsSeen.push(this.currentPuzzleId)
        },
        'puzzles:status': ({ i }) => {
          this.nPuzzlesSolved = i + 1
        },
        'move:fail': (move) => {
          console.log(`mistake! - ${this.currentPuzzleId} - ${move.san}`)
          if (!puzzleIdsMistakes[this.currentPuzzleId]) {
            puzzleIdsMistakes[this.currentPuzzleId] = []
          }
          puzzleIdsMistakes[this.currentPuzzleId].push(move.san)
        },
        'timer:stopped': () => {
          // Cover the board with a dark transluscent overlay after the game ends
          const boardOverlayEl: HTMLElement = document.querySelector('.board-modal-container')
          boardOverlayEl.style.display = ''
          boardOverlayEl.classList.remove('invisible')
          countdownCompleted(levelName, this.nPuzzlesSolved).then(data => {
            const { score, best } = data
            this.score = score
            this.highScore = best
            this.isEnded = true
          })
          // Store the player's mistakes in case they want to view these later
          // Expires from local storage after 1 hour
          store.set(this.viewPuzzlesLink, puzzleIdsMistakes, new Date().getTime() + 86400 * 1000)
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
      })
    },

    components: {
      Timer
    }
  }
</script>
