import store from '@blitz/local_storage'

const puzzleIdsMistakes: Record<number, string[]> = {}

export default {
  data() {
    return {
      hasStarted: false,
      hasFinished: false,
      currentPuzzleId: 0,
      puzzleIdsSeen: [] as number[],
    }
  },

  computed: {
    viewPuzzlesLink(): string {
      return `/puzzles/${this.puzzleIdsSeen.join(',')}`
    }
  },

  methods: {
    showBoardOverlay() {
      const el: HTMLElement = document.querySelector('.board-modal-container')
      if (el) {
        el.style.display = ''
        el.classList.remove('invisible')
      }
    },

    trackPuzzleLoaded(puzzleId: number) {
      this.currentPuzzleId = puzzleId
      this.puzzleIdsSeen.push(puzzleId)
    },

    trackMistake(move: any) {
      console.log(`mistake! - ${this.currentPuzzleId} - ${move.san}`)
      if (!puzzleIdsMistakes[this.currentPuzzleId]) {
        puzzleIdsMistakes[this.currentPuzzleId] = []
      }
      puzzleIdsMistakes[this.currentPuzzleId].push(move.san)
    },

    saveMistakesToStorage() {
      // Store the player's mistakes in case they want to view these later
      // Expires from local storage after 24 hours
      store.set(this.viewPuzzlesLink, puzzleIdsMistakes, new Date().getTime() + 86400 * 1000)
    },

    setupCommonSubscriptions() {
      return {
        'puzzle:loaded': (data: any) => {
          this.trackPuzzleLoaded(data.puzzle.id)
        },
        'move:fail': (move: any) => {
          this.trackMistake(move)
        },
        'move:try': () => {
          if (!this.hasStarted) {
            this.hasStarted = true
          }
        }
      }
    }
  }
} 