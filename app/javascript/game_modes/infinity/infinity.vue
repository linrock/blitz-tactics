<template lang="pug">
aside.infinity-under-board.game-under-board
  .difficulty-section
    .sidebar-label Difficulty:
    .difficulties
      template(v-for="difficulty in difficulties")
        .difficulty(
          :class="[difficulty, { selected: currentDifficulty === difficulty }]"
          @click="chooseDifficulty(difficulty)"
        ) {{ difficulty }}

  .stats(:class="{ invisible: !nPuzzlesSolved }")
    .n-puzzles {{ nPuzzlesSolved }} puzzles solved

    .recent-puzzles
      a.dark-button(href="/infinity/puzzles") Recent puzzles

  .no-more-left(v-if="noMoreLeft")
    | You did it! You solved all the puzzles in this level.
    | Chooose another difficulty to continue.
  
</template>

<script lang="ts">
  import { infinityPuzzleSolved } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import { dispatch, subscribe } from '@blitz/events'

  import { InfinityPuzzleDifficulty } from './index'

  const apiPath = `/infinity/puzzles.json`
  const fetchThreshold = 5 // fetch more puzzles when this # puzzles remain
  const difficulties = ['easy', 'medium', 'hard', 'insane'] as InfinityPuzzleDifficulty[]

  export default {
    data() {
      return {
        nPuzzlesSolved: 0,
        noMoreLeft: false,
        currentDifficulty: 'easy' as InfinityPuzzleDifficulty,
        difficulties,
      }
    },

    methods: {
      chooseDifficulty(difficulty: InfinityPuzzleDifficulty) {
        if (difficulty !== this.currentDifficulty) {
          this.currentDifficulty = difficulty
          dispatch(`source:changed`, `${apiPath}?difficulty=${difficulty}`)
        }
        this.noMoreLeft = false
      },

        async addSolvedPuzzleToList(puzzle: any, difficulty: string) {
          try {
            console.log('Fetching puzzle item for ID:', puzzle.id, 'difficulty:', difficulty)
            // Fetch the server-rendered puzzle item HTML
            const url = `/infinity/recent_puzzle_item?puzzle_id=${puzzle.id}&difficulty=${difficulty}`
            console.log('Request URL:', url)
            const response = await fetch(url)
            console.log('Response status:', response.status, response.statusText)
            if (!response.ok) {
              console.error('Failed to fetch puzzle item, response not ok')
              return
            }
            
            const puzzleItemHTML = await response.text()
            
            // Get the recent puzzles list container
            const recentPuzzlesList = document.getElementById('recent-puzzles-list')
            if (!recentPuzzlesList) return
            
            // Remove the "no recent puzzles" message if it exists
            const noRecentPuzzles = recentPuzzlesList.querySelector('.no-recent-puzzles')
            if (noRecentPuzzles) {
              noRecentPuzzles.remove()
            }
            
            // Add the new puzzle item at the top
            recentPuzzlesList.insertAdjacentHTML('afterbegin', puzzleItemHTML)
            
            // Remove excess items (keep only 5)
            const items = recentPuzzlesList.querySelectorAll('.recent-puzzle-item')
            if (items.length > 5) {
              for (let i = 5; i < items.length; i++) {
                items[i].remove()
              }
            }
            
            // Re-initialize mini chessboards for the new item
            this.initializeMiniChessboards()
          } catch (error) {
            console.error('Failed to add solved puzzle to list:', error)
          }
        },


      updatePuzzleNumbers() {
        const items = document.querySelectorAll('#recent-puzzles-list .recent-puzzle-item')
        items.forEach((item, index) => {
          const numberEl = item.querySelector('.puzzle-number')
          if (numberEl) {
            numberEl.textContent = index + 1
          }
        })
      },

      initializeMiniChessboards() {
        // Re-initialize mini chessboards for new items
        const newChessboards = document.querySelectorAll('#recent-puzzles-list .mini-chessboard:not([data-initialized])')
        newChessboards.forEach((el: HTMLElement) => {
          const { fen, initialMove, initialMoveSan } = el.dataset
          if (fen && initialMove) {
            // Mark as initialized to avoid double initialization
            el.setAttribute('data-initialized', 'true')
            
            // Initialize the mini chessboard
            import('@blitz/components/mini_chessboard').then(({ default: MiniChessboard }) => {
              new MiniChessboard({
                el,
                fen,
                initialMove,
                initialMoveSan,
                flip: false
              })
            })
          }
        })
      }
    },

    mounted() {
      subscribe({
        'config:init': data => {
          this.currentDifficulty = data.difficulty
          this.nPuzzlesSolved = data.num_solved
        },

        'puzzle:solved': puzzle => {
          console.log('Puzzle solved event:', puzzle)
          console.log('Puzzle ID:', puzzle.id)
          console.log('Puzzle object keys:', Object.keys(puzzle))
          
          const puzzleData = {
            puzzle_id: puzzle.id,
            difficulty: this.currentDifficulty
          }
          infinityPuzzleSolved(puzzleData).then(data => {
            if (data.n) {
              this.nPuzzlesSolved = data.n 
            } else {
              this.nPuzzlesSolved = this.nPuzzlesSolved + 1
            }
            
            // Add the solved puzzle to the recent puzzles list
            console.log('Adding solved puzzle to list with ID:', puzzle.id)
            this.addSolvedPuzzleToList(puzzle, this.currentDifficulty)
          })
        },

        'puzzles:status': status => {
          const { i, n, lastPuzzleId } = status
          if (i + fetchThreshold > n) {
            dispatch(
              `source:changed:add`,
              `${apiPath}?difficulty=${this.currentDifficulty}&after_puzzle_id=${lastPuzzleId}`,
            )
          }
        },

        'puzzles:complete': () => {
          this.noMoreLeft = true
        }
      })

      new PuzzlePlayer({
        shuffle: false,
        loopPuzzles: false,
        source: apiPath,
        boardOptions: {
          intentOnly: false, // Disable board movement on hover
        },
      })
    }
  }
</script>
