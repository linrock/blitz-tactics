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

      addSolvedPuzzleToList(puzzle: any, difficulty: string) {
        // Create the new puzzle item HTML
        const puzzleItem = this.createPuzzleItemHTML(puzzle, difficulty)
        
        // Get the recent puzzles list container
        const recentPuzzlesList = document.getElementById('recent-puzzles-list')
        if (!recentPuzzlesList) return
        
        // Remove the "no recent puzzles" message if it exists
        const noRecentPuzzles = recentPuzzlesList.querySelector('.no-recent-puzzles')
        if (noRecentPuzzles) {
          noRecentPuzzles.remove()
        }
        
        // Add the new puzzle item at the top
        recentPuzzlesList.insertAdjacentHTML('afterbegin', puzzleItem)
        
        // Update puzzle numbers for all items
        this.updatePuzzleNumbers()
        
        // Remove excess items (keep only 5)
        const items = recentPuzzlesList.querySelectorAll('.recent-puzzle-item')
        if (items.length > 5) {
          for (let i = 5; i < items.length; i++) {
            items[i].remove()
          }
        }
        
        // Re-initialize mini chessboards for the new item
        this.initializeMiniChessboards()
      },

      createPuzzleItemHTML(puzzle: any, difficulty: string) {
        const now = new Date()
        const timeAgo = 'just now'
        
        // Try to get solution lines from the puzzle object
        const solutionLines = puzzle.lines || puzzle.solution_lines || null
        const solutionLinesJson = solutionLines ? JSON.stringify(solutionLines) : ''
        
        // Get FEN and initial move data safely
        const fen = puzzle.fen || puzzle.initial_fen || ''
        const initialMoveUci = puzzle.initialMove?.uci || puzzle.initial_move_uci || ''
        const initialMoveSan = puzzle.initialMove?.san || puzzle.initial_move_san || ''
        
        return `
          <div class="recent-puzzle-item" data-puzzle-id="${puzzle.id}">
            <div class="puzzle-miniboard">
              <a class="miniboard-link" href="/p/${puzzle.id}">
                <div class="mini-chessboard" 
                     data-fen="${fen}" 
                     data-initial-move="${initialMoveUci}"
                     data-initial-move-san="${initialMoveSan}">
                </div>
              </a>
            </div>
            <div class="puzzle-info">
              <div class="puzzle-meta">
                <div class="puzzle-number">1</div>
                <div class="puzzle-difficulty">Difficulty: ${difficulty}</div>
                <div class="puzzle-time">${timeAgo}</div>
              </div>
              <div class="puzzle-actions">
                <button class="view-solution-btn" 
                        data-puzzle-id="${puzzle.id}"
                        data-initial-fen="${fen}"
                        data-solution-lines="${solutionLinesJson}">View solution</button>
              </div>
            </div>
          </div>
        `
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
