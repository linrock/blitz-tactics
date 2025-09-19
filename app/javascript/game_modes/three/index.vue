<template lang="pug">
aside.three-under-board.game-under-board
  .three-during-game(:style="`display: ${(!hasFinished) ? '' : 'none'}`")
    .timers
      timer
      .n-remaining.n-lives(:class=`{ penalized: isLosingLife }` style="margin-bottom: 0.5rem")
        | {{ numLives }} {{ numLives === 1 ? 'life left' : 'lives' }}
      .n-remaining.n-hints
        | {{ numHints }} {{ numHints === 1 ? 'hint' : 'hints' }}

      // shown during the game
      .hints(v-if="hasStarted && !hasFinished")
        div(v-if="moveHint") Hint: {{ moveHint }}
        div(v-else-if="numHints > 0")
          a.dark-button(@click="viewHint") Use hint

    .right-side
      // shown before the game starts
      .make-a-move(v-if="!hasStarted")
        | Make a move to start the game

      .current-score(v-if="hasStarted && !hasFinished")
        .label Score
        .score(:class=`{ rewarded: isGainingScore }`) {{ numPuzzlesSolved }}

  // shown when the game has finished
  .three-complete(v-if="hasFinished")
    .three-complete-section.scores
      .score-container.your-score
        .label Your score
        .score {{ yourScore }}

      .score-container.high-score
        .label Your high score today
        .score {{ highScore }}

    .three-complete-section.actions
      .action-buttons
        a.view-puzzles.dark-button(:href="viewPuzzlesLink") View puzzles
        a.blue-button(href="/three") Play again


</template>

<script lang="ts">
import { threeRoundCompleted, trackSolvedPuzzle } from '@blitz/api/requests'
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { dispatch, subscribe } from '@blitz/events'

import Timer from './timer.vue'

import './style.sass'
import './responsive.sass'

export default {
  mixins: [GameModeMixin],

  data() {
    return {
      isShowingHint: false,
      isLosingLife: false,
      isGainingScore: false,
      ignoreNextPuzzleScore: false,
      moveHint: null,
      numPuzzlesSolved: 0,
      solvedPuzzleIds: [] as string[],
      numHints: 3,
      numLives: 3,
      yourScore: 0,
      highScore: 0,
      puzzleIdsFailed: [] as number[],
      failedPuzzles: [] as any[],
      highScores: [] as [string, number][],
      currentPuzzle: null as any,
      currentPuzzleData: null as any,
      originalBoardStates: new Map(),
    }
  },

  mounted() {
    const gameOver = async () => {
      if (this.hasFinished) {
        return
      }
      this.showBoardOverlay()
      // Notify the server that the round has finished. Show high scores
      const data = await threeRoundCompleted(this.numPuzzlesSolved, this.solvedPuzzleIds)
      this.yourScore = data.score
      this.highScore = data.best
      this.highScores = data.high_scores
      this.hasFinished = true
      dispatch('timer:stop')
      
      // Show the missed puzzles section if there are any
      console.log('Game over - failed puzzles:', this.failedPuzzles.length)
      if (this.failedPuzzles.length > 0) {
        this.showMissedPuzzlesSection()
      }
    }

    const commonSubscriptions = this.setupCommonSubscriptions()
    
    subscribe({
      ...commonSubscriptions,
      'puzzle:loaded': data => {
        this.moveHint = null
        this.trackPuzzleLoaded(data.puzzle.id)
        // Store current puzzle data for failed puzzle tracking
        this.currentPuzzle = data.puzzle
        this.currentPuzzleData = data
        console.log('Puzzle loaded:', data.puzzle.id, data.puzzle)
      },
      'puzzle:hint': hint => {
        this.numHints -= 1
        const halfHint = Math.random() < 0.5 ? hint.slice(0, 2) : hint.slice(2, 4)
        this.moveHint = halfHint
        dispatch('shape:draw', halfHint)
      },
      'puzzles:status': ({ i }) => {
        // triggered when a puzzle gets loaded onto the board
        if (this.ignoreNextPuzzleScore) {
          // happens after a mistake
          this.ignoreNextPuzzleScore = false
        } else {
          // happens after solving a puzzle
          this.numPuzzlesSolved += 1
          this.isGainingScore = true
          setTimeout(() => this.isGainingScore = false, 300)
        }
      },
      'puzzle:solved': async (puzzle) => {
        if (puzzle && puzzle.id) {
          this.solvedPuzzleIds.push(puzzle.id)
          
          // Send puzzle ID to server immediately for real-time tracking
          try {
            await this.trackSolvedPuzzle(puzzle.id)
          } catch (error) {
            console.error('Failed to track solved puzzle:', error)
          }
        }
      },
      'timer:stopped': () => {
        gameOver();
      },
      'move:success': () => {
        this.hasStarted = true
      },
      'move:fail': () => {
        console.log('Move failed - current puzzle:', this.currentPuzzle)
        console.log('Move failed - current puzzle data:', this.currentPuzzleData)
        
        if (!this.hasStarted) {
          this.hasStarted = true
        }
        if (this.numLives <= 0) {
          console.log('No lives left, not adding to failed puzzles')
          return
        }
        this.numLives -= 1
        this.puzzleIdsFailed.push(this.currentPuzzleId)
        
        // Store the full puzzle data for the missed puzzle
        if (this.currentPuzzle) {
          this.failedPuzzles.push({
            puzzle: this.currentPuzzle,
            puzzle_data: this.currentPuzzleData
          })
          console.log('Added failed puzzle:', this.currentPuzzle.id, 'Total failed:', this.failedPuzzles.length)
        } else {
          console.log('No current puzzle available to add to failed puzzles')
        }
        
        if (this.numLives > 0) {
          // move on to the next puzzle after a mistake
          this.ignoreNextPuzzleScore = true
          this.isLosingLife = true
          setTimeout(() => this.isLosingLife = false, 500)
          dispatch('puzzles:next')
        } else {
          // if not enough lives, the game is over
          gameOver()
        }
      },
      'move:try': () => {
        this.moveHint = null
        if (!this.hasStarted) {
          this.hasStarted = true
        }
        commonSubscriptions['move:try']()
      }
    })

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      noHint: true,
      source: '/three/puzzles',
    })
  },

  methods: {
    viewHint() {
      dispatch('puzzle:get_hint')
    },

    async trackSolvedPuzzle(puzzleId) {
      // Track puzzle with game mode
      try {
        return await trackSolvedPuzzle(puzzleId, 'three')
      } catch (error) {
        console.error('Failed to track solved puzzle:', error)
        throw error
      }
    },

    showSolution(puzzleData) {
      // Show the solution for the missed puzzle
      console.log('showSolution called with:', puzzleData)
      console.log('Available properties:', Object.keys(puzzleData))
      console.log('Puzzle lines:', puzzleData.puzzle?.lines)
      
      // Find the corresponding miniboard and replay the solution
      const puzzleId = puzzleData.puzzle?.id
      if (puzzleId) {
        const miniboard = document.querySelector(`#missed-puzzles-section .mini-chessboard[data-puzzle-id="${puzzleId}"]`)
        if (miniboard) {
          // Use the puzzle lines for the solution
          const solutionLines = puzzleData.puzzle?.lines
          if (solutionLines) {
            this.replaySolutionOnMiniboard(miniboard, solutionLines)
          } else {
            console.log('No solution lines found for puzzle:', puzzleId)
          }
        } else {
          console.log('Miniboard not found for puzzle:', puzzleId)
        }
      }
    },

    async replaySolutionOnMiniboard(miniboardEl, solutionLines) {
      if (!solutionLines) {
        console.log('No solution lines available')
        return
      }

      const solutionMoves = this.extractSolutionMoves(solutionLines)
      
      if (solutionMoves.length === 0) {
        console.log('No solution moves found')
        return
      }

      console.log('Playing solution moves:', solutionMoves)
      
      const initialFen = miniboardEl.getAttribute('data-fen')
      if (!initialFen) {
        console.error('No initial FEN found for miniboard')
        return
      }

      // Play the solution moves
      this.playMovesInMiniboard(miniboardEl, initialFen, solutionMoves)
    },

    playMovesInMiniboard(miniboard, initialFen, moves) {
      if (moves.length === 0) {
        return
      }

      // Reset board to original position before playing solution
      this.resetBoardToOriginalPosition(miniboard)
      
      let currentMoveIndex = 0
      
      const playNextMove = () => {
        if (currentMoveIndex < moves.length) {
          // Clear initial move highlighting before the first solution move
          if (currentMoveIndex === 0) {
            this.clearExistingHighlights(miniboard)
          }
          
          const moveUci = moves[currentMoveIndex]
          this.animateMoveOnMiniboard(miniboard, moveUci)
          currentMoveIndex++
          
          setTimeout(playNextMove, 700) // 0.7 second delay between moves
        }
      }
      
      // Start playing moves after reset completes
      setTimeout(playNextMove, 200)
    },

    resetBoardToOriginalPosition(miniboard) {
      const originalFen = miniboard.getAttribute('data-fen')
      const originalMove = miniboard.getAttribute('data-initial-move')
      
      if (!originalFen) {
        console.warn('No original FEN data found for reset')
        return
      }

      // Store the current state first time we see this board
      if (!this.originalBoardStates.has(originalFen)) {
        this.storeOriginalBoardState(miniboard, originalFen)
      }

      // Restore from stored state
      this.restoreFromStoredState(miniboard, originalFen, originalMove)
    },

    storeOriginalBoardState(miniboard, fen) {
      const squares = miniboard.querySelectorAll('.square')
      const pieces = []
      
      squares.forEach((square, index) => {
        const piece = square.querySelector('.piece')
        if (piece) {
          // Clone the piece to store its exact state
          const pieceClone = piece.cloneNode(true)
          pieces.push({ squareIndex: index, piece: pieceClone })
        }
      })
      
      this.originalBoardStates.set(fen, {
        pieces,
        initialMove: miniboard.getAttribute('data-initial-move')
      })
    },

    restoreFromStoredState(miniboard, fen, originalMove) {
      const storedState = this.originalBoardStates.get(fen)
      if (!storedState) {
        console.warn('No stored state found for FEN:', fen)
        return
      }

      // Clear all current pieces
      const squares = miniboard.querySelectorAll('.square')
      squares.forEach(square => {
        const pieces = square.querySelectorAll('.piece')
        pieces.forEach(piece => piece.remove())
      })

      // Restore pieces to their original positions using square indices
      storedState.pieces.forEach(({ squareIndex, piece }) => {
        if (squareIndex >= 0 && squareIndex < squares.length) {
          const pieceClone = piece.cloneNode(true)
          squares[squareIndex].appendChild(pieceClone)
        }
      })

      // Restore initial move highlighting
      if (originalMove) {
        setTimeout(() => {
          this.restoreInitialMoveHighlighting(miniboard, originalMove)
        }, 50)
      }
    },

    restoreInitialMoveHighlighting(miniboard, moveUci) {
      if (!moveUci || moveUci.length < 4) return
      
      const fromSquare = moveUci.substring(0, 2)
      const toSquare = moveUci.substring(2, 4)
      
      const squares = miniboard.querySelectorAll('.square')
      const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
      const toSquareEl = this.getSquareByPosition(squares, toSquare)
      
      if (fromSquareEl) fromSquareEl.classList.add('move-from')
      if (toSquareEl) toSquareEl.classList.add('move-to')
    },

    clearExistingHighlights(miniboard) {
      // Remove any existing move-from and move-to classes from all squares
      const highlightedSquares = miniboard.querySelectorAll('.square.move-from, .square.move-to')
      highlightedSquares.forEach(square => {
        square.classList.remove('move-from', 'move-to')
      })
    },

    animateMoveOnMiniboard(miniboard, moveUci) {
      const fromSquare = moveUci.substring(0, 2)
      const toSquare = moveUci.substring(2, 4)
      
      // Get all squares from the miniboard
      const squares = miniboard.querySelectorAll('.square')
      
      // Find squares by position index
      const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
      const toSquareEl = this.getSquareByPosition(squares, toSquare)
      
      if (!fromSquareEl || !toSquareEl) {
        console.warn(`Could not find squares ${fromSquare} or ${toSquare} on miniboard`)
        return
      }

      // Simulate piece movement
      this.simulatePieceMovement(fromSquareEl, toSquareEl)
    },

    simulatePieceMovement(fromSquareEl, toSquareEl) {
      // Get the piece from the 'from' square
      const pieceEl = fromSquareEl.querySelector('.piece')
      if (!pieceEl) {
        // If no piece, just highlight squares
        this.highlightSquares(fromSquareEl, toSquareEl)
        return
      }

      // Clone the piece element
      const pieceClone = pieceEl.cloneNode(true)
      
      // Highlight squares and move the piece
      fromSquareEl.classList.add('move-from')
      toSquareEl.classList.add('move-to')
      
      // Move the piece immediately
      pieceEl.remove()
      
      // Remove any existing piece from destination square
      const existingPiece = toSquareEl.querySelector('.piece')
      if (existingPiece) {
        existingPiece.remove()
      }
      
      // Add the piece to the destination square
      toSquareEl.appendChild(pieceClone)
      
      // Clean up square highlighting after a delay
      setTimeout(() => {
        fromSquareEl.classList.remove('move-from')
        toSquareEl.classList.remove('move-to')
      }, 600)
    },

    highlightSquares(fromSquareEl, toSquareEl) {
      // Fallback: just highlight squares if no piece to move
      fromSquareEl.classList.add('move-from')
      toSquareEl.classList.add('move-to')
      
      setTimeout(() => {
        fromSquareEl.classList.remove('move-from')
        toSquareEl.classList.remove('move-to')
      }, 800)
    },

    getSquareByPosition(squares, squareId) {
      // Get the miniboard element to check if it's flipped
      const miniboard = squares[0]?.closest('.mini-chessboard')
      const isFlipped = miniboard?.getAttribute('data-flip') === 'true'
      
      // Convert square notation (e.g., "e4") to board index
      const file = squareId.charAt(0) // 'a' to 'h'
      const rank = parseInt(squareId.charAt(1)) // 1 to 8
      
      // Convert to 0-based indices
      let fileIndex = file.charCodeAt(0) - 'a'.charCodeAt(0) // 0 to 7
      let rankIndex = 8 - rank // 0 to 7 (rank 8 = index 0, rank 1 = index 7)
      
      // If the board is flipped, reverse both file and rank indices
      if (isFlipped) {
        fileIndex = 7 - fileIndex // Flip horizontally
        rankIndex = 7 - rankIndex // Flip vertically
      }
      
      // Calculate the index in the squares array
      const squareIndex = rankIndex * 8 + fileIndex
      
      return squares[squareIndex] || null
    },
    
    extractSolutionMoves(lines) {
      const moves = []
      
      const traverse = (node) => {
        if (typeof node === 'string') {
          return // Reached a terminal node
        }
        
        for (const [move, child] of Object.entries(node)) {
          if (child === 'win') {
            moves.push(move)
            return
          } else if (typeof child === 'object') {
            moves.push(move)
            traverse(child)
            return
          }
        }
      }
      
      traverse(lines)
      return moves
    },

    showMissedPuzzlesSection() {
      const missedSection = document.getElementById('missed-puzzles-section')
      const missedList = document.getElementById('missed-puzzles-list')
      
      if (!missedSection || !missedList) return
      
      // Clear existing content
      missedList.innerHTML = ''
      
      // Create HTML for each missed puzzle
      this.failedPuzzles.slice(0, 3).forEach((puzzleData, index) => {
        console.log('Creating puzzle item for index', index, 'puzzleData:', puzzleData)
        console.log('Puzzle object:', puzzleData.puzzle)
        console.log('Puzzle data:', puzzleData.puzzle_data)
        console.log('Puzzle ID:', puzzleData.puzzle?.puzzle_id || puzzleData.puzzle?.id)
        
        const puzzleId = puzzleData.puzzle?.id || 'Unknown'
        
        // Use the actual property names from the puzzle object
        const initialFen = puzzleData.puzzle?.fen
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
        console.log('Initial FEN:', initialFen)
        console.log('Final initial move UCI:', initialMoveUci)
        console.log('Puzzle object keys:', Object.keys(puzzleData.puzzle || {}))
        
        const puzzleItem = document.createElement('div')
        puzzleItem.className = 'missed-puzzle-item'
        puzzleItem.innerHTML = `
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
            <div class="puzzle-meta">Puzzle ${puzzleId}</div>
            <div class="puzzle-actions">
              <button class="view-solution-btn" data-puzzle-index="${index}">Show Solution</button>
            </div>
          </div>
        `
        missedList.appendChild(puzzleItem)
      })
      
      // Show the section
      missedSection.style.display = 'block'
      
      // Prevent horizontal scrollbar on body
      document.body.style.overflowX = 'hidden'
      
      // Initialize miniboards
      this.initializeMissedPuzzleMiniboards()
      
      // Add click handlers for solution buttons (with a small delay to ensure DOM is ready)
      setTimeout(() => {
        this.addSolutionButtonHandlers()
      }, 100)
    },

    initializeMissedPuzzleMiniboards() {
      // Initialize miniboards for missed puzzles
      const miniboards = document.querySelectorAll('#missed-puzzles-section .mini-chessboard:not([data-initialized])')
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
      const solutionButtons = document.querySelectorAll('#missed-puzzles-section .view-solution-btn')
      console.log('Found solution buttons:', solutionButtons.length)
      solutionButtons.forEach((button: HTMLElement) => {
        button.addEventListener('click', (e) => {
          e.preventDefault()
          console.log('Solution button clicked')
          const puzzleIndex = parseInt(button.dataset.puzzleIndex || '0')
          const puzzleData = this.failedPuzzles[puzzleIndex]
          console.log('Puzzle index:', puzzleIndex, 'Puzzle data:', puzzleData)
          if (puzzleData) {
            this.showSolution(puzzleData)
          }
        })
      })
    }
  },

  components: {
    Timer,
  }
}
</script>
