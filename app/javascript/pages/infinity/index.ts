import { uciToMove } from '@blitz/utils'
import MiniChessboard from '@blitz/components/mini_chessboard'

// Solution player for recent puzzles - plays directly in miniboards
export class SolutionPlayer {
  private playingSolutions: Set<string> = new Set()

  constructor() {
    this.setupEventListeners()
  }

  private setupEventListeners() {
    // View solution buttons
    document.addEventListener('click', (e) => {
      const target = e.target as HTMLElement
      if (target && target.classList.contains('view-solution-btn')) {
        e.preventDefault()
        this.playSolutionInMiniboard(target)
      }
    })
  }

  private async playSolutionInMiniboard(button: HTMLElement) {
    const buttonEl = button as HTMLButtonElement
    const puzzleId = button.getAttribute('data-puzzle-id')
    const initialFen = button.getAttribute('data-initial-fen')
    const solutionLinesJson = button.getAttribute('data-solution-lines')
    
    if (!puzzleId || !initialFen) {
      console.error('Missing puzzle data for solution playback')
      return
    }

    // Prevent multiple simultaneous plays
    if (this.playingSolutions.has(puzzleId)) {
      return
    }
    
    // Change button text to indicate what's happening
    const originalText = button.textContent
    button.textContent = 'Showing solution...'

    // Update button state - fade out instead of changing text
    button.style.opacity = '0.5'
    buttonEl.disabled = true
    this.playingSolutions.add(puzzleId)

    try {
      let solutionLines = null
      
      // Try to use embedded solution data first
      if (solutionLinesJson && solutionLinesJson.trim()) {
        solutionLines = JSON.parse(solutionLinesJson)
      } else {
        // Fallback: fetch solution data from server
        const response = await fetch(`/p/${puzzleId}.json`)
        const puzzleData = await response.json()
        solutionLines = puzzleData.puzzle_data?.lines || puzzleData.lines
      }
      
      if (!solutionLines) {
        console.warn('No solution data available')
        button.textContent = originalText || 'Show solution'
        button.style.opacity = '1'
        buttonEl.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      const solutionMoves = this.extractSolutionMoves(solutionLines)
      
      if (solutionMoves.length === 0) {
        console.warn('No solution moves found')
        button.textContent = originalText || 'Show solution'
        button.style.opacity = '1'
        buttonEl.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      // Find the miniboard for this puzzle - look for both recent-puzzle-item and puzzle-item containers
      const puzzleItem = button.closest('.recent-puzzle-item') || button.closest('.puzzle-item')
      const miniboard = puzzleItem?.querySelector('.mini-chessboard')
      
      if (!miniboard) {
        console.error('Could not find miniboard for puzzle')
        button.textContent = originalText || 'Show solution'
        button.style.opacity = '1'
        buttonEl.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      // Button remains faded during playback

      // Play the solution
      this.playMovesInMiniboard(miniboard, initialFen, solutionMoves, () => {
        // Reset button when done - fade back in
        button.textContent = originalText || 'Show solution'
        button.style.opacity = '1'
        buttonEl.disabled = false
        this.playingSolutions.delete(puzzleId)
      })

    } catch (error) {
      console.error('Failed to load or parse solution data:', error)
      button.textContent = originalText || 'Show solution'
      button.style.opacity = '1'
      buttonEl.disabled = false
      this.playingSolutions.delete(puzzleId)
    }
  }

  private playMovesInMiniboard(miniboard: Element, initialFen: string, moves: string[], onComplete: () => void) {
    if (moves.length === 0) {
      onComplete()
      return
    }

    // Start playing moves from current position - no reset needed
    console.log('Starting solution from current board position')
    
    let currentMoveIndex = 0
    
    const playNextMove = () => {
      if (currentMoveIndex < moves.length) {
        // Clear existing move highlighting before the first solution move
        if (currentMoveIndex === 0) {
          this.clearExistingHighlights(miniboard)
        }
        
        const moveUci = moves[currentMoveIndex]
        this.animateMoveOnMiniboard(miniboard, moveUci)
        currentMoveIndex++
        
        setTimeout(playNextMove, 700) // 0.7 second delay between moves
      } else {
        onComplete()
      }
    }
    
    // Start playing moves immediately from current position
    setTimeout(playNextMove, 100)
  }

  private clearExistingHighlights(miniboard: Element) {
    // Remove any existing move-from and move-to classes from all squares
    const highlightedSquares = miniboard.querySelectorAll('.square.move-from, .square.move-to')
    highlightedSquares.forEach(square => {
      square.classList.remove('move-from', 'move-to')
    })
  }

  private resetBoardToOriginalPosition(miniboard: Element) {
    const originalFen = miniboard.getAttribute('data-fen')
    const originalMove = miniboard.getAttribute('data-initial-move')
    
    console.log('resetBoardToOriginalPosition called with:', { originalFen, originalMove })
    
    if (!originalFen) {
      console.warn('No original FEN data found for reset')
      return
    }

    // Check if there's a stored miniboard instance we can reset directly
    const miniboardInstance = (miniboard as any).miniboardInstance
    if (miniboardInstance) {
      console.log('Found miniboard instance, resetting chess position to:', originalFen)
      
      try {
        // Access the internal chess.js instance
        const cjs = (miniboardInstance as any).cjs
        if (cjs) {
          console.log('Current FEN before reset:', cjs.fen())
          
          // Reset to original FEN
          cjs.load(originalFen)
          console.log('FEN after reset:', cjs.fen())
          
          // Clear highlights
          const highlights = (miniboardInstance as any).highlights
          if (highlights) {
            Object.keys(highlights).forEach(key => delete highlights[key])
          }
          
          // Force re-render by calling the private renderFen method
          const renderFen = (miniboardInstance as any).renderFen
          if (renderFen && typeof renderFen === 'function') {
            renderFen.call(miniboardInstance, originalFen)
            console.log('Forced re-render with original FEN')
          }
          
          // Apply initial move if present
          if (originalMove && originalMove !== '') {
            setTimeout(() => {
              try {
                console.log('Applying initial move:', originalMove)
                const moveResult = cjs.move({
                  from: originalMove.slice(0, 2),
                  to: originalMove.slice(2, 4),
                  promotion: originalMove.length > 4 ? originalMove[4] : undefined
                })
                
                if (moveResult) {
                  // Highlight the move
                  const highlightSquare = (miniboardInstance as any).highlightSquare
                  if (highlightSquare && typeof highlightSquare === 'function') {
                    highlightSquare.call(miniboardInstance, moveResult.from, 'move-from')
                    highlightSquare.call(miniboardInstance, moveResult.to, 'move-to')
                  }
                  
                  // Re-render with the move
                  if (renderFen && typeof renderFen === 'function') {
                    renderFen.call(miniboardInstance, cjs.fen())
                  }
                }
                
                console.log('Board reset complete with initial move')
              } catch (error) {
                console.warn('Failed to apply initial move:', error)
              }
            }, 100)
          } else {
            console.log('Board reset complete without initial move')
          }
        } else {
          console.warn('Could not access chess.js instance')
        }
      } catch (error) {
        console.error('Error resetting miniboard:', error)
      }
    } else {
      console.warn('No miniboard instance found, falling back to DOM manipulation')
      // Fallback to the old method if no instance is available
      if (!this.originalBoardStates.has(originalFen)) {
        this.storeOriginalBoardState(miniboard, originalFen)
      }
      this.restoreFromStoredState(miniboard, originalFen, originalMove)
    }
  }

  // Store original board states to avoid re-parsing FEN
  private originalBoardStates = new Map<string, {
    pieces: { squareIndex: number, piece: Element }[],
    initialMove: string | null
  }>()

  private storeOriginalBoardState(miniboard: Element, fen: string) {
    const squares = miniboard.querySelectorAll('.square')
    const pieces: { squareIndex: number, piece: Element }[] = []
    
    squares.forEach((square, index) => {
      const piece = square.querySelector('.piece')
      if (piece) {
        // Clone the piece to store its exact state
        const pieceClone = piece.cloneNode(true) as Element
        pieces.push({ squareIndex: index, piece: pieceClone })
      }
    })
    
    this.originalBoardStates.set(fen, {
      pieces,
      initialMove: miniboard.getAttribute('data-initial-move')
    })
  }

  private restoreFromStoredState(miniboard: Element, fen: string, originalMove: string | null) {
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
        const pieceClone = piece.cloneNode(true) as Element
        squares[squareIndex].appendChild(pieceClone)
      }
    })

    // Restore initial move highlighting
    if (originalMove) {
      setTimeout(() => {
        this.restoreInitialMoveHighlighting(miniboard, originalMove)
      }, 50)
    }
  }


  private restoreInitialMoveHighlighting(miniboard: Element, moveUci: string) {
    if (moveUci.length < 4) return
    
    const fromSquare = moveUci.substring(0, 2)
    const toSquare = moveUci.substring(2, 4)
    
    const squares = miniboard.querySelectorAll('.square')
    const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
    const toSquareEl = this.getSquareByPosition(squares, toSquare)
    
    if (fromSquareEl) fromSquareEl.classList.add('move-from')
    if (toSquareEl) toSquareEl.classList.add('move-to')
  }






  private animateMoveOnMiniboard(miniboard: Element, moveUci: string) {
    console.log('animateMoveOnMiniboard called with move:', moveUci)
    console.log('Miniboard element:', miniboard)
    console.log('Miniboard classes:', miniboard.className)
    console.log('Miniboard attributes:', miniboard.attributes)
    
    // Try to make the move directly in the chess.js instance and re-render
    const miniboardInstance = (miniboard as any).miniboardInstance
    console.log('Miniboard instance:', miniboardInstance)
    
    if (miniboardInstance) {
      console.log('Found miniboard instance, making move in chess.js')
      
      const cjs = (miniboardInstance as any).cjs
      if (cjs) {
        try {
          console.log('Current FEN before move:', cjs.fen())
          
          // Make the move in chess.js
          const moveResult = cjs.move({
            from: moveUci.slice(0, 2),
            to: moveUci.slice(2, 4),
            promotion: moveUci.length > 4 ? moveUci[4] : undefined
          })
          
          if (moveResult) {
            console.log('Move made successfully:', moveResult)
            console.log('New FEN after move:', cjs.fen())
            
            // Clear previous highlights
            const highlights = (miniboardInstance as any).highlights
            if (highlights) {
              Object.keys(highlights).forEach(key => delete highlights[key])
            }
            
            // Add new highlights for this move
            const highlightSquare = (miniboardInstance as any).highlightSquare
            if (highlightSquare && typeof highlightSquare === 'function') {
              highlightSquare.call(miniboardInstance, moveResult.from, 'move-from')
              highlightSquare.call(miniboardInstance, moveResult.to, 'move-to')
            }
            
            // Force re-render to show the new position
            const renderFen = (miniboardInstance as any).renderFen
            if (renderFen && typeof renderFen === 'function') {
              renderFen.call(miniboardInstance, cjs.fen())
              console.log('Board re-rendered with new position')
            }
          } else {
            console.warn('Failed to make move:', moveUci)
          }
        } catch (error) {
          console.error('Error making move:', error)
        }
      } else {
        console.warn('Could not access chess.js instance')
      }
    } else {
      console.warn('No miniboard instance found, falling back to DOM manipulation')
      // Fallback to old method
      const fromSquare = moveUci.substring(0, 2)
      const toSquare = moveUci.substring(2, 4)
      
      const squares = miniboard.querySelectorAll('.square')
      const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
      const toSquareEl = this.getSquareByPosition(squares, toSquare)
      
      if (fromSquareEl && toSquareEl) {
        this.simulatePieceMovement(fromSquareEl, toSquareEl)
      }
    }
  }

  private simulatePieceMovement(fromSquareEl: Element, toSquareEl: Element) {
    // Get the piece from the 'from' square
    const pieceEl = fromSquareEl.querySelector('.piece')
    if (!pieceEl) {
      // If no piece, just highlight squares
      this.highlightSquares(fromSquareEl, toSquareEl)
      return
    }

    // Clone the piece element
    const pieceClone = pieceEl.cloneNode(true) as Element
    
    // Simply move the piece without animations - just highlight squares
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
  }

  private highlightSquares(fromSquareEl: Element, toSquareEl: Element) {
    // Fallback: just highlight squares if no piece to move
    fromSquareEl.classList.add('move-from')
    toSquareEl.classList.add('move-to')
    
    setTimeout(() => {
      fromSquareEl.classList.remove('move-from')
      toSquareEl.classList.remove('move-to')
    }, 800)
  }

  private getSquareByPosition(squares: NodeListOf<Element>, squareId: string): Element | null {
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
  }

  private extractSolutionMoves(lines: any): string[] {
    const moves: string[] = []
    
    const traverse = (node: any): void => {
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
  }
}

// Initialize solution player
export default () => {
  new SolutionPlayer()
}