<template lang="pug">
aside.speedrun-under-board.game-under-board
  .timers(:style="{ display: hasStarted && !hasCompleted ? '' : 'none' }")
    .current-run
      timer
      .description {{ puzzleIdx }} of {{ numPuzzles }} solved

  .speedrun-complete(v-if="hasCompleted")
    .timers-section
      .timer-container.accuracy(:class="{ 'perfect-accuracy': isPerfectAccuracy }")
        .label Accuracy
        .timer {{ accuracyPercentage }}

      .timer-container.your-time
        .label Your time
        .timer {{ formattedYourTime }}

      .timer-container.personal-best
        .label Personal best
        .timer {{ formattedBestTime }}

    .action-buttons
      a.blue-button(href="/speedrun") Play again

  template(v-if="!hasStarted")
    .make-a-move Make a move to start the timer

</template>

<script lang="ts">
  import { speedrunCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
  import PuzzlePlayer from '@blitz/components/puzzle_player'
  import GameModeMixin from '@blitz/components/game_mode_mixin'
  import MiniChessboard from '@blitz/components/mini_chessboard'
  import { subscribe, GameEvent } from '@blitz/events'
  import { formattedTime } from '@blitz/utils'
  import { solutionReplay } from '@blitz/utils/solution_replay'

  import Timer from './timer.vue'

  import './style.sass'
  import './responsive.sass'

  const apiPath = `/speedrun/puzzles.json`

  export default {
    mixins: [GameModeMixin],

    data() {
      return {
        hasCompleted: false,
        lebelName: null,
        numPuzzles: 0,
        puzzleIdx: 0,
        bestTime: 0,
        yourTime: 0,
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
      formattedYourTime(): string {
        return formattedTime(parseInt(this.yourTime as any, 0))
      },
      formattedBestTime(): string {
        return formattedTime(parseInt(this.bestTime, 0))
      },
      accuracyPercentage(): string {
        if (this.totalMoves === 0) return '0%'
        const percentage = Math.round((this.correctMoves / this.totalMoves) * 100)
        return `${percentage}%`
      },
      isPerfectAccuracy(): boolean {
        if (this.totalMoves === 0) return false
        const percentage = Math.round((this.correctMoves / this.totalMoves) * 100)
        return percentage === 100
      }
    },

    mounted() {
      const commonSubscriptions = this.setupCommonSubscriptions()

      // Subscribe to common events first
      subscribe(commonSubscriptions)
      
      // Then subscribe to speedrun-specific events
      subscribe({
        [GameEvent.CONFIG_INIT]: data => {
          this.levelName = data.level_name
        },

        [GameEvent.PUZZLE_LOADED]: data => {
          // Track each puzzle loaded (including puzzle data)
          this.currentPuzzle = data.puzzle
          this.currentPuzzleData = data
          this.currentPuzzleStartTime = Date.now()
          this.currentPuzzleMistakes = 0 // Reset mistakes for new puzzle
          console.log('Puzzle loaded:', data.puzzle.id, 'Start time:', this.currentPuzzleStartTime)
        },

        [GameEvent.MOVE_TRY]: () => {
          // Handle hasStarted for speedrun mode
          if (!this.hasStarted) {
            this.hasStarted = true
          }
          // Track total moves
          this.totalMoves++
        },

        [GameEvent.MOVE_FAIL]: () => {
          // Track mistakes for current puzzle
          this.currentPuzzleMistakes++
          console.log('Mistake made on puzzle:', this.currentPuzzle?.id, 'Total mistakes:', this.currentPuzzleMistakes)
        },

        [GameEvent.MOVE_SUCCESS]: () => {
          // Track correct moves
          this.correctMoves++
        },

        [GameEvent.PUZZLE_SOLVED]: (puzzle) => {
          // Track individual puzzle solve
          if (puzzle && puzzle.id) {
            trackSolvedPuzzle(puzzle.id, 'speedrun').catch(error => {
              console.error('Failed to track solved puzzle:', error)
            })
            
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
          }
        },
        
        [GameEvent.TIMER_STOPPED]: elapsedTimeMs => {
          console.log('timer:stopped', elapsedTimeMs)
          const boardOverlayEl: HTMLElement = document.querySelector(`.board-modal-container`)
          boardOverlayEl.style.display = ``
          boardOverlayEl.classList.remove(`invisible`)
          this.yourTime = elapsedTimeMs
          
          // Note: In speedrun mode, the game only ends with a successful puzzle solve,
          // so the current puzzle is already added to playedPuzzles in the puzzle:solved handler
          
          speedrunCompleted(this.levelName, elapsedTimeMs).then(data => {
            console.log('speedrun completed!')
            this.bestTime = data.best
            this.hasCompleted = true
            
            // Show the played puzzles section if there are any
            console.log('Game over - played puzzles:', this.playedPuzzles.length)
            if (this.playedPuzzles.length > 0) {
              this.showPlayedPuzzlesSection()
            }
          })
        },

        [GameEvent.PUZZLES_FETCHED]: puzzles => {
          this.puzzleIdx = 0
          this.numPuzzles = puzzles.length
        },

        [GameEvent.PUZZLES_STATUS]: ({ i , n }) => {
          this.puzzleIdx = i + 1
          this.numPuzzles = n
        },
      })

      new PuzzlePlayer({
        shuffle: false,
        loopPuzzles: false,
        source: apiPath,
      })
    },

    methods: {
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
          } else if (!isSolved && solveTime) {
            timeDisplayHtml = `<div class="unsolved-status">Spent ${solveTime}s</div>`
          }
          
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
              flip: flip === 'true',
              initialMove: validInitialMove,
            })
            
            // Store the miniboard instance on the element for potential cleanup
            ;(el as any).miniboardInstance = miniboard
          }
        })
      },

      addSolutionButtonHandlers() {
        // Add click handlers for solution buttons
        const solutionButtons = document.querySelectorAll('#played-puzzles-section .view-solution-btn')
        solutionButtons.forEach((button: HTMLElement) => {
          button.addEventListener('click', (e) => {
            e.preventDefault()
            const puzzleIndex = parseInt(button.dataset.puzzleIndex || '0')
            const puzzleData = this.playedPuzzles[puzzleIndex]
            
            if (puzzleData && puzzleData.puzzle) {
              // Use the working solution replay utility
              const puzzleId = puzzleData.puzzle.id
              const miniboard = document.querySelector(`#played-puzzles-section .mini-chessboard[data-puzzle-id="${puzzleId}"]`)
              if (miniboard) {
                // Use the puzzle lines for the solution (same as three game mode)
                const solutionLines = puzzleData.puzzle.lines
                if (solutionLines) {
                  solutionReplay.replaySolutionOnMiniboard(miniboard, solutionLines)
                } else {
                  console.log('No solution lines found for puzzle:', puzzleId)
                }
              } else {
                console.log('Miniboard not found for puzzle:', puzzleId)
              }
            }
          })
        })
      },

    },

    components: {
      Timer,
    }
  }
</script>
