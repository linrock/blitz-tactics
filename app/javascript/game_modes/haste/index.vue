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
      a.blue-button(href="/haste") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { hasteRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { subscribe, GameEvent } from '@blitz/events'
import { solutionReplay } from '@blitz/utils/solution_replay'

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
      playedPuzzles: [] as any[],
      currentPuzzle: null as any,
      currentPuzzleData: null as any,
      currentPuzzleStartTime: null as number | null,
      currentPuzzleMistakes: 0,
    }
  },

  mounted() {
    const commonSubscriptions = this.setupCommonSubscriptions()
    
    subscribe({
      ...commonSubscriptions,
      [GameEvent.PUZZLE_LOADED]: data => {
        // Track each puzzle loaded (including puzzle data)
        this.currentPuzzle = data.puzzle
        this.currentPuzzleData = data
        this.currentPuzzleStartTime = Date.now()
        this.currentPuzzleMistakes = 0 // Reset mistakes for new puzzle
        console.log('Puzzle loaded:', data.puzzle.id, 'Start time:', this.currentPuzzleStartTime)
      },
      [GameEvent.MOVE_FAIL]: () => {
        // Track mistakes for current puzzle
        this.currentPuzzleMistakes++
        console.log('Mistake made on puzzle:', this.currentPuzzle?.id, 'Total mistakes:', this.currentPuzzleMistakes)
      },
      [GameEvent.PUZZLES_STATUS]: ({ i }) => {
        this.numPuzzlesSolved = i + 1
      },
      [GameEvent.PUZZLE_SOLVED]: async (puzzle) => {
        console.log('Puzzle solved:', puzzle)
        if (puzzle && puzzle.id) {
          this.solvedPuzzleIds.push(puzzle.id)
          console.log('Added puzzle ID:', puzzle.id, 'Total solved:', this.solvedPuzzleIds.length)
          
          // Calculate solve time
          const endTime = Date.now()
          const solveTimeMs = this.currentPuzzleStartTime ? endTime - this.currentPuzzleStartTime : 0
          const solveTimeSeconds = Math.round(solveTimeMs / 100) / 10 // Round to 1 decimal place
          
          // Track this puzzle in the played puzzles list with timing data
          if (this.currentPuzzle) {
            this.playedPuzzles.push({
              puzzle: this.currentPuzzle,
              puzzle_data: this.currentPuzzleData,
              solveTime: solveTimeSeconds,
              mistakes: this.currentPuzzleMistakes,
              puzzleNumber: this.playedPuzzles.length + 1, // Will be reversed later
              solved: true
            })
            console.log('Added played puzzle:', this.currentPuzzle.id, 'Solve time:', solveTimeSeconds + 's', 'Mistakes:', this.currentPuzzleMistakes, 'Total played:', this.playedPuzzles.length)
          }
          
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
      [GameEvent.TIMER_STOPPED]: async () => {
        this.showBoardOverlay()
        console.log('Round completed. Sending puzzle IDs:', this.solvedPuzzleIds)
        // Notify the server that the round has finished. Show high scores
        const data = await hasteRoundCompleted(this.numPuzzlesSolved, this.solvedPuzzleIds)
        this.yourScore = data.score
        this.highScore = data.best
        this.highScores = data.high_scores
        this.hasFinished = true
        this.saveMistakesToStorage()
        
        // Add the current unsolved puzzle to the list if there is one
        if (this.currentPuzzle) {
          this.playedPuzzles.push({
            puzzle: this.currentPuzzle,
            puzzle_data: this.currentPuzzleData,
            solveTime: null, // Not solved
            mistakes: this.currentPuzzleMistakes,
            puzzleNumber: null, // No number for unsolved puzzle
            solved: false
          })
          console.log('Added unsolved puzzle:', this.currentPuzzle.id, 'Mistakes:', this.currentPuzzleMistakes)
        }
        
        // Show the played puzzles section if there are any
        console.log('Game over - played puzzles:', this.playedPuzzles.length)
        if (this.playedPuzzles.length > 0) {
          this.showPlayedPuzzlesSection()
        }
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
    },

    showPlayedPuzzlesSection() {
      const playedSection = document.getElementById('played-puzzles-section')
      const playedList = document.getElementById('played-puzzles-list')
      
      if (!playedSection || !playedList) return
      
      // Clear existing content
      playedList.innerHTML = ''
      
      // Separate solved and unsolved puzzles
      const solvedPuzzles = this.playedPuzzles.filter(p => p.solved)
      const unsolvedPuzzles = this.playedPuzzles.filter(p => !p.solved)
      
      // Show unsolved puzzle first (most recent), then solved puzzles in reverse order
      const allPuzzlesToShow = [...unsolvedPuzzles.reverse(), ...solvedPuzzles.reverse()]
      
      allPuzzlesToShow.forEach((puzzleData, index) => {
        console.log('Creating puzzle item for index', index, 'puzzleData:', puzzleData)
        
        const puzzleId = puzzleData.puzzle?.id || 'Unknown'
        const initialFen = puzzleData.puzzle?.fen
        const solveTime = puzzleData.solveTime
        const mistakes = puzzleData.mistakes || 0
        const isSolved = puzzleData.solved
        
        // Calculate puzzle number (only for solved puzzles, in reverse order: 7, 6, 5, 4, 3, 2, 1)
        let puzzleNumber = null
        if (isSolved) {
          // Find the original solve order index
          const originalSolvedIndex = solvedPuzzles.findIndex(p => p.puzzle?.id === puzzleId)
          // Reverse the numbering: if 7 puzzles solved, first solved = 7, last solved = 1
          puzzleNumber = solvedPuzzles.length - originalSolvedIndex
        }
        
        let initialMove = puzzleData.puzzle?.initialMove
        let initialMoveUci = null
        
        // Extract UCI move from initialMove object
        if (initialMove) {
          if (typeof initialMove === 'object' && initialMove.uci) {
            // Expected format: {san: "Rxc7", uci: "a7c7"}
            initialMoveUci = initialMove.uci
            console.log('Found initial move UCI:', initialMoveUci)
          } else if (typeof initialMove === 'string' && initialMove.length >= 4) {
            // Fallback: already a UCI string
            if (/^[a-h][1-8][a-h][1-8]/.test(initialMove)) {
              initialMoveUci = initialMove
              console.log('Initial move is already UCI string:', initialMoveUci)
            }
          } else {
            console.log('Invalid initial move format:', typeof initialMove, initialMove)
          }
        } else {
          console.log('No initial move found')
        }
        
        console.log('Puzzle ID:', puzzleId)
        console.log('Puzzle Number:', puzzleNumber)
        console.log('Solve Time:', solveTime)
        console.log('Mistakes:', mistakes)
        console.log('Is Solved:', isSolved)
        console.log('Initial FEN:', initialFen)
        console.log('Final initial move UCI:', initialMoveUci)
        
        // Find the original index for solution button data
        const originalIndex = this.playedPuzzles.findIndex(p => p.puzzle?.id === puzzleId)
        
        const puzzleItem = document.createElement('div')
        puzzleItem.className = 'played-puzzle-item'
        
        // Build the HTML with conditional elements
        let numberBadgeHtml = ''
        if (puzzleNumber) {
          numberBadgeHtml = `<div class="puzzle-number">${puzzleNumber}</div>`
        }
        
        let mistakeBadgeHtml = ''
        if (mistakes > 0) {
          mistakeBadgeHtml = `<div class="mistake-badge">${mistakes} mistake${mistakes > 1 ? 's' : ''}</div>`
        }
        
        let timeDisplayHtml = ''
        if (isSolved && solveTime) {
          timeDisplayHtml = `<div class="solve-time">Solved in ${solveTime}s</div>`
        }
        // For unsolved puzzles, leave timeDisplayHtml empty (no text shown)
        
        puzzleItem.innerHTML = `
          ${numberBadgeHtml}
          ${mistakeBadgeHtml}
          <div class="puzzle-miniboard">
            <a href="/puzzles/${puzzleId}" class="miniboard-link">
              <div class="mini-chessboard" 
                   data-fen="${initialFen}" 
                   data-initial-move="${initialMoveUci || ''}" 
                   data-flip="${initialFen && initialFen.includes(' w ')}"
                   data-puzzle-id="${puzzleId}">
              </div>
            </a>
          </div>
          <div class="puzzle-info">
            <div class="puzzle-meta">
              <div class="puzzle-id">Puzzle ${puzzleId}</div>
              ${timeDisplayHtml}
            </div>
            <div class="puzzle-actions">
              <button class="view-solution-btn" data-puzzle-index="${originalIndex}">Show Solution</button>
            </div>
          </div>
        `
        playedList.appendChild(puzzleItem)
      })
      
      // Show the section
      playedSection.style.display = 'block'
      
      // Prevent horizontal scrollbar on body
      document.body.style.overflowX = 'hidden'
      
      // Initialize miniboards
      this.initializePlayedPuzzleMiniboards()
      
      // Add click handlers for solution buttons (with a small delay to ensure DOM is ready)
      setTimeout(() => {
        this.addSolutionButtonHandlers()
      }, 100)
    },

    initializePlayedPuzzleMiniboards() {
      // Initialize miniboards for played puzzles
      const miniboards = document.querySelectorAll('#played-puzzles-section .mini-chessboard:not([data-initialized])')
      miniboards.forEach((el: HTMLElement) => {
        const { fen, initialMove, flip } = el.dataset
        if (fen) {
          el.setAttribute('data-initialized', 'true')
          
          // Additional validation before passing to MiniChessboard
          let validInitialMove = initialMove
          if (initialMove && initialMove !== '') {
            // Check if it's a valid UCI move format
            if (!/^[a-h][1-8][a-h][1-8]/.test(initialMove)) {
              console.log('Filtering out invalid move in MiniChessboard:', initialMove)
              validInitialMove = undefined // Don't pass invalid moves
            }
          }
          
          console.log('Initializing MiniChessboard with:', { fen, initialMove: validInitialMove, flip })
          
          // Initialize the mini chessboard
          import('@blitz/components/mini_chessboard').then(({ default: MiniChessboard }) => {
            new MiniChessboard({
              el,
              fen,
              initialMove: validInitialMove,
              flip: flip === 'true'
            })
          })
        }
      })
    },

    addSolutionButtonHandlers() {
      // Add click handlers for solution buttons
      const solutionButtons = document.querySelectorAll('#played-puzzles-section .view-solution-btn')
      console.log('Found solution buttons:', solutionButtons.length)
      solutionButtons.forEach((button) => {
        const buttonEl = button as HTMLButtonElement
        buttonEl.addEventListener('click', (e) => {
          e.preventDefault()
          console.log('Solution button clicked')
          
          // Prevent multiple clicks while playing solution
          if (buttonEl.disabled) {
            return
          }
          
          const puzzleIndex = parseInt(buttonEl.dataset.puzzleIndex || '0')
          const puzzleData = this.playedPuzzles[puzzleIndex]
          console.log('Puzzle index:', puzzleIndex, 'Puzzle data:', puzzleData)
          if (puzzleData) {
            this.showSolutionWithButtonState(puzzleData, buttonEl)
          }
        })
      })
    },

    showSolutionWithButtonState(puzzleData, buttonEl) {
      // Store original button state
      const originalText = buttonEl.textContent
      
      // Update button to show progress state
      buttonEl.textContent = 'Showing solution...'
      buttonEl.style.opacity = '0.5'
      buttonEl.disabled = true
      
      // Find the corresponding miniboard and replay the solution
      const puzzleId = puzzleData.puzzle?.id
      if (puzzleId) {
        const miniboard = document.querySelector(`#played-puzzles-section .mini-chessboard[data-puzzle-id="${puzzleId}"]`)
        if (miniboard) {
          // Use the puzzle lines for the solution (same as three game mode)
          const solutionLines = puzzleData.puzzle?.lines
          if (solutionLines) {
            solutionReplay.replaySolutionOnMiniboardWithCallback(miniboard, solutionLines, () => {
              // Reset button state when solution playback is complete
              buttonEl.textContent = originalText || 'Show solution'
              buttonEl.style.opacity = '1'
              buttonEl.disabled = false
            })
          } else {
            console.log('No solution lines found for puzzle:', puzzleId)
            // Reset button state on error
            buttonEl.textContent = originalText || 'Show solution'
            buttonEl.style.opacity = '1'
            buttonEl.disabled = false
          }
        } else {
          console.log('Miniboard not found for puzzle:', puzzleId)
          // Reset button state on error
          buttonEl.textContent = originalText || 'Show solution'
          buttonEl.style.opacity = '1'
          buttonEl.disabled = false
        }
      }
    },

  }
}
</script>
