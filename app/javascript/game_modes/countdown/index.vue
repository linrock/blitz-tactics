<template lang="pug">
aside.countdown-under-board.game-under-board
  .timers(:style="{ display: (hasStarted && !hasFinished) ? '' : 'none'}")
    .current-countdown
      timer
      .description {{ nPuzzlesSolved }} puzzles solved

  .countdown-complete(v-if="hasFinished")
    .score-section
      .score-container.accuracy
        .label Accuracy
        .score(:class="{ 'perfect-accuracy': isPerfectAccuracy }") {{ accuracyPercentage }}%

      .score-container.your-score
        .label Your score
        .score {{ score }}

      .score-container.high-score
        .label High score
        .score {{ highScore }}

    .action-buttons
      a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
      a.blue-button(href="/countdown") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { countdownCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import MiniChessboard from '@blitz/components/mini_chessboard'
import { subscribe } from '@blitz/events'
import { solutionReplay } from '@blitz/utils/solution_replay'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin],

  data() {
    return {
      nPuzzlesSolved: 0,
      score: 0,
      highScore: 0,
      playedPuzzles: [] as any[],
      currentPuzzle: null as any,
      currentPuzzleData: null as any,
      currentPuzzleStartTime: null as number | null,
      currentPuzzleMistakes: 0,
      totalMoves: 0,
      correctMoves: 0,
    }
  },

  computed: {
    accuracyPercentage() {
      if (this.totalMoves === 0) return 0
      return Math.round((this.correctMoves / this.totalMoves) * 100)
    },

    isPerfectAccuracy() {
      return this.totalMoves > 0 && this.correctMoves === this.totalMoves
    }
  },

  mounted() {
    let levelName: string
    const commonSubscriptions = this.setupCommonSubscriptions()

    // Subscribe to common events first
    subscribe(commonSubscriptions)
    
    // Then subscribe to countdown-specific events
    subscribe({
      'config:init': data => levelName = data.level_name,
      'puzzle:loaded': data => {
        // Track each puzzle loaded (including puzzle data)
        this.currentPuzzle = data.puzzle
        this.currentPuzzleData = data
        this.currentPuzzleStartTime = Date.now()
        this.currentPuzzleMistakes = 0 // Reset mistakes for new puzzle
        console.log('Puzzle loaded:', data.puzzle.id, 'Start time:', this.currentPuzzleStartTime)
      },
      'move:fail': () => {
        // Track mistakes for current puzzle
        this.currentPuzzleMistakes++
        console.log('Mistake made on puzzle:', this.currentPuzzle?.id, 'Total mistakes:', this.currentPuzzleMistakes)
      },
      'puzzles:status': ({ i }) => {
        this.nPuzzlesSolved = i + 1
      },
      'puzzle:solved': (puzzle) => {
        // Track individual puzzle solve
        console.log('Countdown puzzle solved:', puzzle)
        if (puzzle && puzzle.id) {
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
            console.log('Added solved puzzle:', this.currentPuzzle.id, 'Time:', solveTimeSeconds + 's', 'Mistakes:', this.currentPuzzleMistakes, 'Total played:', this.playedPuzzles.length)
          }
          
          trackSolvedPuzzle(puzzle.id, 'countdown').catch(error => {
            console.error('Failed to track solved puzzle:', error)
          })
        }
      },
      'timer:stopped': () => {
        this.showBoardOverlay()
        
        // Add the current unsolved puzzle to the list if there is one
        if (this.currentPuzzle) {
          // Calculate time spent on current puzzle
          const endTime = Date.now()
          const solveTimeMs = this.currentPuzzleStartTime ? endTime - this.currentPuzzleStartTime : 0
          const solveTimeSeconds = Math.round(solveTimeMs / 100) / 10 // Round to 1 decimal place
          
          this.playedPuzzles.push({
            puzzle: this.currentPuzzle,
            puzzle_data: this.currentPuzzleData,
            solveTime: solveTimeSeconds, // Time spent even if not solved
            mistakes: this.currentPuzzleMistakes,
            puzzleNumber: null, // No number for unsolved puzzle
            solved: false
          })
          console.log('Added unsolved puzzle:', this.currentPuzzle.id, 'Time:', solveTimeSeconds + 's', 'Mistakes:', this.currentPuzzleMistakes)
        }
        
        countdownCompleted(levelName, this.nPuzzlesSolved).then(data => {
          const { score, best } = data
          this.score = score
          this.highScore = best
          this.hasFinished = true
          
          // Show the played puzzles section if there are any
          console.log('Game over - played puzzles:', this.playedPuzzles.length)
          if (this.playedPuzzles.length > 0) {
            this.showPlayedPuzzlesSection()
          }
        })
        this.saveMistakesToStorage()
      },
      'move:try': move => {
        // Set hasStarted on first move
        if (!this.hasStarted) {
          this.hasStarted = true
        }
        // Track total moves for accuracy calculation
        this.totalMoves++
      },
      'move:success': () => {
        // Track correct moves for accuracy calculation
        this.correctMoves++
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noCounter: true,
      noHint: true,
      source: '/countdown/puzzles.json',
    })
  },

  methods: {
    async trackSolvedPuzzle(puzzleId) {
      // Track puzzle with game mode
      try {
        return await trackSolvedPuzzle(puzzleId, 'countdown')
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
        
        // Calculate puzzle number (only for solved puzzles, in reverse order)
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
          
          // Initialize the mini chessboard and store instance on element
          const miniboard = new MiniChessboard({
            el,
            fen,
            initialMove: validInitialMove,
            flip: flip === 'true'
          })
          
          // Store the miniboard instance on the element for potential cleanup
          ;(el as any).miniboardInstance = miniboard
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

  },

  components: {
    Timer
  }
}
</script>
