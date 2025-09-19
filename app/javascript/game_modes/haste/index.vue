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
      a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
      a.blue-button(href="/haste") Play again

  .make-a-move(v-if="!hasStarted") Make a move to start the timer

</template>

<script lang="ts">
import { hasteRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { subscribe } from '@blitz/events'

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
    }
  },

  mounted() {
    const commonSubscriptions = this.setupCommonSubscriptions()
    
    subscribe({
      ...commonSubscriptions,
      'puzzle:loaded': data => {
        // Track each puzzle loaded (including puzzle data)
        this.currentPuzzle = data.puzzle
        this.currentPuzzleData = data
        this.currentPuzzleStartTime = Date.now()
        console.log('Puzzle loaded:', data.puzzle.id, 'Start time:', this.currentPuzzleStartTime)
      },
      'puzzles:status': ({ i }) => {
        this.numPuzzlesSolved = i + 1
      },
      'puzzle:solved': async (puzzle) => {
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
              puzzleNumber: this.playedPuzzles.length + 1 // Will be reversed later
            })
            console.log('Added played puzzle:', this.currentPuzzle.id, 'Solve time:', solveTimeSeconds + 's', 'Total played:', this.playedPuzzles.length)
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
      'timer:stopped': async () => {
        this.showBoardOverlay()
        console.log('Round completed. Sending puzzle IDs:', this.solvedPuzzleIds)
        // Notify the server that the round has finished. Show high scores
        const data = await hasteRoundCompleted(this.numPuzzlesSolved, this.solvedPuzzleIds)
        this.yourScore = data.score
        this.highScore = data.best
        this.highScores = data.high_scores
        this.hasFinished = true
        this.saveMistakesToStorage()
        
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
      
      // Create HTML for each played puzzle (in reverse order, latest first)
      const reversedPuzzles = [...this.playedPuzzles].reverse()
      reversedPuzzles.forEach((puzzleData, index) => {
        console.log('Creating puzzle item for index', index, 'puzzleData:', puzzleData)
        
        const puzzleId = puzzleData.puzzle?.id || 'Unknown'
        const initialFen = puzzleData.puzzle?.fen
        const solveTime = puzzleData.solveTime || 0
        const puzzleNumber = this.playedPuzzles.length - index // Reverse numbering: last = highest number
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
        console.log('Solve Time:', solveTime + 's')
        console.log('Initial FEN:', initialFen)
        console.log('Final initial move UCI:', initialMoveUci)
        
        // Find the original index for solution button data
        const originalIndex = this.playedPuzzles.findIndex(p => p.puzzle?.id === puzzleId)
        
        const puzzleItem = document.createElement('div')
        puzzleItem.className = 'played-puzzle-item'
        puzzleItem.innerHTML = `
          <div class="puzzle-number">${puzzleNumber}</div>
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
              <div class="solve-time">${solveTime}s</div>
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
          // Use the puzzle lines for the solution
          const solutionLines = puzzleData.puzzle?.lines
          if (solutionLines) {
            this.replaySolutionOnMiniboardWithCallback(miniboard, solutionLines, () => {
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

    async replaySolutionOnMiniboardWithCallback(miniboardEl, solutionLines, onComplete) {
      if (!solutionLines) {
        console.log('No solution lines available')
        onComplete()
        return
      }

      const solutionMoves = this.extractSolutionMoves(solutionLines)
      
      if (solutionMoves.length === 0) {
        console.log('No solution moves found')
        onComplete()
        return
      }

      console.log('Playing solution moves:', solutionMoves)
      
      const initialFen = miniboardEl.getAttribute('data-fen')
      if (!initialFen) {
        console.error('No initial FEN found for miniboard')
        onComplete()
        return
      }

      // Play the solution moves with callback when complete
      this.playMovesInMiniboardWithCallback(miniboardEl, initialFen, solutionMoves, onComplete)
    },

    extractSolutionMoves(solutionLines) {
      // Extract moves from the solution tree structure
      const moves = []
      
      if (solutionLines && typeof solutionLines === 'object') {
        // Recursively traverse the solution tree to collect moves
        const traverseLines = (lines) => {
          if (lines && typeof lines === 'object') {
            for (const [moveUci, nextLines] of Object.entries(lines)) {
              if (moveUci && moveUci.match(/^[a-h][1-8][a-h][1-8]/)) {
                moves.push(moveUci)
                // Only follow the first line of the solution
                if (nextLines && typeof nextLines === 'object') {
                  traverseLines(nextLines)
                }
                break // Only take the first move from each level
              }
            }
          }
        }
        
        traverseLines(solutionLines)
      }
      
      return moves
    },

    playMovesInMiniboardWithCallback(miniboard, initialFen, moves, onComplete) {
      if (moves.length === 0) {
        onComplete()
        return
      }

      let currentMoveIndex = 0
      
      const playNextMove = () => {
        if (currentMoveIndex < moves.length) {
          const moveUci = moves[currentMoveIndex]
          this.animateMoveOnMiniboard(miniboard, moveUci)
          currentMoveIndex++
          
          setTimeout(playNextMove, 700) // 0.7 second delay between moves
        } else {
          // All moves completed, call the callback
          onComplete()
        }
      }
      
      // Start playing moves
      setTimeout(playNextMove, 200)
    },

    animateMoveOnMiniboard(miniboard, moveUci) {
      // Simple animation by moving pieces between squares based on UCI notation
      if (!moveUci || moveUci.length < 4) return
      
      const fromSquare = moveUci.substring(0, 2)
      const toSquare = moveUci.substring(2, 4)
      
      // Find the squares in the miniboard
      const squares = miniboard.querySelectorAll('.square')
      const squareMap = {}
      
      squares.forEach((square, index) => {
        const file = String.fromCharCode(97 + (index % 8)) // 'a' + file index
        const rank = 8 - Math.floor(index / 8) // rank from 8 to 1
        const squareName = file + rank
        squareMap[squareName] = square
      })
      
      const fromEl = squareMap[fromSquare]
      const toEl = squareMap[toSquare]
      
      if (fromEl && toEl) {
        // Move the piece
        const piece = fromEl.querySelector('.piece')
        if (piece) {
          // Remove any existing piece on the target square
          const existingPiece = toEl.querySelector('.piece')
          if (existingPiece) {
            existingPiece.remove()
          }
          
          // Move the piece
          toEl.appendChild(piece)
        }
      }
    }
  }
}
</script>
