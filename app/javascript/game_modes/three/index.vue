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
      playedPuzzles: [] as any[],
      highScores: [] as [string, number][],
      currentPuzzle: null as any,
      currentPuzzleData: null as any,
      originalBoardStates: new Map(),
      currentPuzzleStartTime: null as number | null,
      currentPuzzleMistakes: 0,
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
      
      // Add the current unsolved puzzle to the list if there is one and it hasn't been added already
      if (this.currentPuzzle) {
        const alreadyAdded = this.playedPuzzles.some(p => p.puzzle?.id === this.currentPuzzle.id)
        if (!alreadyAdded) {
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
        } else {
          console.log('Current puzzle already in played list, skipping')
        }
      }
      
      // Show the played puzzles section if there are any
      console.log('Game over - played puzzles:', this.playedPuzzles.length)
      if (this.playedPuzzles.length > 0) {
        this.showPlayedPuzzlesSection()
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
        this.currentPuzzleStartTime = Date.now()
        this.currentPuzzleMistakes = 0 // Reset mistakes for new puzzle
        console.log('Puzzle loaded:', data.puzzle.id, 'Start time:', this.currentPuzzleStartTime)
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
        
        // Track mistakes for current puzzle
        this.currentPuzzleMistakes++
        console.log('Mistake made on puzzle:', this.currentPuzzle?.id, 'Total mistakes:', this.currentPuzzleMistakes)
        
        if (!this.hasStarted) {
          this.hasStarted = true
        }
        if (this.numLives <= 0) {
          console.log('No lives left, not adding to failed puzzles')
          return
        }
        this.numLives -= 1
        this.puzzleIdsFailed.push(this.currentPuzzleId)
        
        // Calculate time spent on failed puzzle
        const endTime = Date.now()
        const solveTimeMs = this.currentPuzzleStartTime ? endTime - this.currentPuzzleStartTime : 0
        const solveTimeSeconds = Math.round(solveTimeMs / 100) / 10 // Round to 1 decimal place
        
        // Store the full puzzle data for the failed puzzle with timing and mistakes
        if (this.currentPuzzle) {
          this.playedPuzzles.push({
            puzzle: this.currentPuzzle,
            puzzle_data: this.currentPuzzleData,
            solveTime: solveTimeSeconds,
            mistakes: this.currentPuzzleMistakes,
            puzzleNumber: null, // No number for failed puzzles
            solved: false
          })
          console.log('Added failed puzzle:', this.currentPuzzle.id, 'Time:', solveTimeSeconds + 's', 'Mistakes:', this.currentPuzzleMistakes, 'Total played:', this.playedPuzzles.length)
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

    showSolutionWithButtonState(puzzleData, button) {
      // Store original button state
      const originalText = button.textContent
      
      // Update button to show progress state
      button.textContent = 'Showing solution...'
      button.style.opacity = '0.5'
      button.disabled = true
      
      // Find the corresponding miniboard and replay the solution
      const puzzleId = puzzleData.puzzle?.id
      if (puzzleId) {
        const miniboard = document.querySelector(`#missed-puzzles-section .mini-chessboard[data-puzzle-id="${puzzleId}"]`)
        if (miniboard) {
          // Use the puzzle lines for the solution
          const solutionLines = puzzleData.puzzle?.lines
          if (solutionLines) {
            this.replaySolutionOnMiniboardWithCallback(miniboard, solutionLines, () => {
              // Reset button state when solution playback is complete
              button.textContent = originalText || 'Show solution'
              button.style.opacity = '1'
              button.disabled = false
            })
          } else {
            console.log('No solution lines found for puzzle:', puzzleId)
            // Reset button state on error
            button.textContent = originalText || 'Show solution'
            button.style.opacity = '1'
            button.disabled = false
          }
        } else {
          console.log('Miniboard not found for puzzle:', puzzleId)
          // Reset button state on error
          button.textContent = originalText || 'Show solution'
          button.style.opacity = '1'
          button.disabled = false
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

    playMovesInMiniboardWithCallback(miniboard, initialFen, moves, onComplete) {
      if (moves.length === 0) {
        onComplete()
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
        } else {
          // All moves completed, call the callback
          onComplete()
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

    showPlayedPuzzlesSection() {
      const playedSection = document.getElementById('missed-puzzles-section')
      const playedList = document.getElementById('missed-puzzles-list')
      
      if (!playedSection || !playedList) return
      
      // Clear existing content
      playedList.innerHTML = ''
      
      // Separate solved and unsolved puzzles
      const solvedPuzzles = this.playedPuzzles.filter(p => p.solved)
      const unsolvedPuzzles = this.playedPuzzles.filter(p => !p.solved)
      
      // Show unsolved puzzle first (most recent), then solved puzzles in reverse order
      const allPuzzlesToShow = [...unsolvedPuzzles.reverse(), ...solvedPuzzles.reverse()]
      
      // Create HTML for each played puzzle (in reverse order, latest first)
      allPuzzlesToShow.forEach((puzzleData, index) => {
        console.log('Creating puzzle item for index', index, 'puzzleData:', puzzleData)
        
        const puzzleId = puzzleData.puzzle?.id || 'Unknown'
        const solveTime = puzzleData.solveTime
        const mistakes = puzzleData.mistakes || 0
        const isSolved = puzzleData.solved
        
        // Calculate puzzle number (only for solved puzzles, in reverse order)
        let puzzleNumber = null
        if (isSolved) {
          const originalSolvedIndex = solvedPuzzles.findIndex(p => p.puzzle?.id === puzzleId)
          // Reverse the numbering: if 7 puzzles solved, first solved = 7, last solved = 1
          puzzleNumber = solvedPuzzles.length - originalSolvedIndex
        }
        
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
        console.log('Solve Time:', solveTime)
        console.log('Mistakes:', mistakes)
        console.log('Is Solved:', isSolved)
        console.log('Initial FEN:', initialFen)
        console.log('Final initial move UCI:', initialMoveUci)
        
        // Find the original index for solution button data
        const originalIndex = this.playedPuzzles.findIndex(p => p.puzzle?.id === puzzleId)
        
        // Build conditional HTML elements
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
          timeDisplayHtml = `<div class="spent-time">Spent ${solveTime}s</div>`
        }
        // For puzzles with no timing data, leave timeDisplayHtml empty
        
        const puzzleItem = document.createElement('div')
        puzzleItem.className = 'missed-puzzle-item'
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
        this.addPlayedPuzzleSolutionButtonHandlers()
      }, 100)
    },

    initializePlayedPuzzleMiniboards() {
      // Initialize miniboards for played puzzles
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

    addPlayedPuzzleSolutionButtonHandlers() {
      // Add click handlers for solution buttons
      const solutionButtons = document.querySelectorAll('#missed-puzzles-section .view-solution-btn')
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
    }
  },

  components: {
    Timer,
  }
}
</script>
