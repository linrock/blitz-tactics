/**
 * Reusable solution replay utility for miniboards
 * Extracted from working implementations in three/haste/countdown game modes
 */

export class SolutionReplay {
  private originalBoardStates = new Map()

  /**
   * Replay a solution on a miniboard
   * @param miniboardEl - The miniboard DOM element
   * @param solutionLines - The puzzle solution lines data
   */
  async replaySolutionOnMiniboard(miniboardEl: HTMLElement, solutionLines: any) {
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
  }

  /**
   * Replay a solution on a miniboard with callback when complete
   * @param miniboardEl - The miniboard DOM element
   * @param solutionLines - The puzzle solution lines data
   * @param onComplete - Callback function when replay is complete
   */
  async replaySolutionOnMiniboardWithCallback(miniboardEl: HTMLElement, solutionLines: any, onComplete: () => void) {
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
  }

  /**
   * Extract solution moves from puzzle lines data
   * @param lines - The puzzle lines data structure
   * @returns Array of UCI moves
   */
  extractSolutionMoves(lines: any): string[] {
    console.log('extractSolutionMoves called with:', lines)
    console.log('Lines type:', typeof lines)
    console.log('Lines is array:', Array.isArray(lines))
    console.log('Lines keys:', Object.keys(lines || {}))
    
    const moves: string[] = []
    
    // Recursive function to traverse the solution tree and collect UCI moves
    const traverseSolutionTree = (obj: any, depth: number = 0): void => {
      if (!obj || typeof obj !== 'object') return
      
      const indent = '  '.repeat(depth)
      console.log(`${indent}Traversing solution tree at depth ${depth}:`, obj)
      console.log(`${indent}Object keys:`, Object.keys(obj))
      
      // Look for keys that are UCI moves (4+ characters matching UCI pattern)
      Object.keys(obj).forEach(key => {
        if (key && key.length >= 4 && /^[a-h][1-8][a-h][1-8]/.test(key)) {
          console.log(`${indent}Found UCI move key:`, key)
          console.log(`${indent}Key value:`, obj[key])
          
          // Add this UCI move to our sequence
          moves.push(key)
          console.log(`${indent}Added move to sequence:`, key)
          
          // If the value is an object (not 'win' or other terminal), continue traversing
          if (obj[key] && typeof obj[key] === 'object' && obj[key] !== 'win') {
            traverseSolutionTree(obj[key], depth + 1)
          } else {
            console.log(`${indent}Reached terminal state:`, obj[key])
          }
        }
      })
    }
    
    // Handle the actual data structure: solution tree
    if (lines && typeof lines === 'object' && !Array.isArray(lines)) {
      traverseSolutionTree(lines)
    } else if (Array.isArray(lines)) {
      // Fallback: handle array structure if it exists
      const traverse = (node: any) => {
        console.log('Traversing node:', node)
        console.log('Node type:', typeof node)
        console.log('Node keys:', Object.keys(node || {}))
        
        if (node && node.move) {
          console.log('Found move:', node.move)
          moves.push(node.move)
        }
        if (node && node.children) {
          console.log('Found children:', node.children)
          node.children.forEach(traverse)
        }
      }
      
      traverse(lines)
    }
    
    console.log('Extracted moves in sequence:', moves)
    return moves
  }

  /**
   * Play moves on a miniboard
   * @param miniboard - The miniboard DOM element
   * @param initialFen - The initial FEN position
   * @param moves - Array of UCI moves to play
   */
  playMovesInMiniboard(miniboard: HTMLElement, initialFen: string, moves: string[]) {
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
        const isLastMove = currentMoveIndex === moves.length - 1
        this.animateMoveOnMiniboard(miniboard, moveUci, isLastMove)
        currentMoveIndex++
        
        setTimeout(playNextMove, 700) // 0.7 second delay between moves
      }
    }
    
    // Start playing moves after reset completes
    setTimeout(playNextMove, 200)
  }

  /**
   * Play moves on a miniboard with callback when complete
   * @param miniboard - The miniboard DOM element
   * @param initialFen - The initial FEN position
   * @param moves - Array of UCI moves to play
   * @param onComplete - Callback function when all moves are complete
   */
  playMovesInMiniboardWithCallback(miniboard: HTMLElement, initialFen: string, moves: string[], onComplete: () => void) {
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
        const isLastMove = currentMoveIndex === moves.length - 1
        this.animateMoveOnMiniboard(miniboard, moveUci, isLastMove)
        currentMoveIndex++
        
        setTimeout(playNextMove, 700) // 0.7 second delay between moves
      } else {
        // All moves completed, call the callback
        onComplete()
      }
    }
    
    // Start playing moves after reset completes
    setTimeout(playNextMove, 200)
  }

  /**
   * Reset miniboard to original position
   * @param miniboard - The miniboard DOM element
   */
  resetBoardToOriginalPosition(miniboard: HTMLElement) {
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
  }

  /**
   * Store the original board state
   * @param miniboard - The miniboard DOM element
   * @param fen - The FEN string
   */
  storeOriginalBoardState(miniboard: HTMLElement, fen: string) {
    const squares = miniboard.querySelectorAll('.square')
    const pieces: any[] = []
    
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
  }

  /**
   * Restore miniboard from stored state
   * @param miniboard - The miniboard DOM element
   * @param fen - The FEN string
   * @param originalMove - The original move UCI
   */
  restoreFromStoredState(miniboard: HTMLElement, fen: string, originalMove: string | null) {
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

    // Restore original pieces
    storedState.pieces.forEach(({ squareIndex, piece }: any) => {
      const targetSquare = squares[squareIndex]
      if (targetSquare) {
        targetSquare.appendChild(piece)
      }
    })

    // Restore initial move highlighting if it exists
    if (originalMove && originalMove !== '') {
      setTimeout(() => {
        this.highlightInitialMove(miniboard, originalMove)
      }, 100)
    }
  }

  /**
   * Highlight the initial move on the miniboard
   * @param miniboard - The miniboard DOM element
   * @param moveUci - The move UCI string
   */
  highlightInitialMove(miniboard: HTMLElement, moveUci: string) {
    const fromSquare = moveUci.substring(0, 2)
    const toSquare = moveUci.substring(2, 4)
    
    const squares = miniboard.querySelectorAll('.square')
    const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
    const toSquareEl = this.getSquareByPosition(squares, toSquare)
    
    if (fromSquareEl && toSquareEl) {
      fromSquareEl.classList.add('move-from')
      toSquareEl.classList.add('move-to')
    }
  }

  /**
   * Clear existing move highlights
   * @param miniboard - The miniboard DOM element
   */
  clearExistingHighlights(miniboard: HTMLElement) {
    const squares = miniboard.querySelectorAll('.square')
    squares.forEach(square => {
      square.classList.remove('move-from', 'move-to')
    })
  }

  /**
   * Animate a move on the miniboard
   * @param miniboard - The miniboard DOM element
   * @param moveUci - The move UCI string
   * @param isLastMove - Whether this is the last move in the solution
   */
  animateMoveOnMiniboard(miniboard: HTMLElement, moveUci: string, isLastMove: boolean = false) {
    const fromSquare = moveUci.substring(0, 2)
    const toSquare = moveUci.substring(2, 4)
    
    console.log(`Animating move: ${moveUci} (${fromSquare} -> ${toSquare})`)
    
    // Get all squares from the miniboard
    const squares = miniboard.querySelectorAll('.square')
    console.log(`Found ${squares.length} squares on miniboard`)
    
    // Find squares by position index
    const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
    const toSquareEl = this.getSquareByPosition(squares, toSquare)
    
    if (!fromSquareEl || !toSquareEl) {
      console.warn(`Could not find squares ${fromSquare} or ${toSquare} on miniboard`)
      console.log('Available squares:', Array.from(squares).map((sq, i) => ({ index: i, element: sq })))
      return
    }

    console.log(`Found from square:`, fromSquareEl)
    console.log(`Found to square:`, toSquareEl)

    // Simulate piece movement
    this.simulatePieceMovement(fromSquareEl, toSquareEl, isLastMove)
  }

  /**
   * Get square element by position
   * @param squares - NodeList of square elements
   * @param squareId - The square ID (e.g., "e4")
   * @returns The square element or null
   */
  getSquareByPosition(squares: NodeListOf<Element>, squareId: string): Element | null {
    // Get the miniboard element to check if it's flipped
    const miniboard = squares[0]?.closest('.mini-chessboard')
    const isFlipped = miniboard?.getAttribute('data-flip') === 'true'
    
    console.log(`Getting square ${squareId}, isFlipped: ${isFlipped}`)
    
    // Convert square notation (e.g., "e4") to board index
    const file = squareId.charAt(0) // 'a' to 'h'
    const rank = parseInt(squareId.charAt(1)) // 1 to 8
    
    // Convert to 0-based indices
    let fileIndex = file.charCodeAt(0) - 'a'.charCodeAt(0) // 0 to 7
    let rankIndex = 8 - rank // 0 to 7 (rank 8 = index 0, rank 1 = index 7)
    
    console.log(`Original calculation: file=${fileIndex}, rank=${rankIndex}`)
    
    // If the board is flipped, reverse both file and rank indices
    if (isFlipped) {
      fileIndex = 7 - fileIndex // Flip horizontally
      rankIndex = 7 - rankIndex // Flip vertically
      console.log(`After flipping: file=${fileIndex}, rank=${rankIndex}`)
    }
    
    // Calculate the index in the squares array
    const squareIndex = rankIndex * 8 + fileIndex
    
    console.log(`Final square index: ${squareIndex}`)
    console.log(`Total squares: ${squares.length}`)
    console.log(`Target square element:`, squares[squareIndex])
    
    // Debug: show the actual square positions for first few squares
    if (squareIndex < 8) {
      console.log('First row squares:', Array.from(squares).slice(0, 8).map((sq, i) => ({ index: i, element: sq })))
    }
    
    return squares[squareIndex] || null
  }

  /**
   * Simulate piece movement between squares
   * @param fromSquareEl - The source square element
   * @param toSquareEl - The destination square element
   * @param isLastMove - Whether this is the last move in the solution
   */
  simulatePieceMovement(fromSquareEl: Element, toSquareEl: Element, isLastMove: boolean = false) {
    // Get the piece from the 'from' square
    const pieceEl = fromSquareEl.querySelector('.piece')
    if (!pieceEl) {
      // If no piece, just highlight squares
      this.highlightSquares(fromSquareEl, toSquareEl, isLastMove)
      return
    }

    // Clone the piece element
    const pieceClone = pieceEl.cloneNode(true)
    
    // Highlight squares and move the piece
    fromSquareEl.classList.add('move-from')
    toSquareEl.classList.add('move-to')
    
    // Remove the original piece
    pieceEl.remove()
    
    // Remove any existing piece from destination square
    const existingPiece = toSquareEl.querySelector('.piece')
    if (existingPiece) {
      existingPiece.remove()
    }
    
    // Add the cloned piece to the destination square
    toSquareEl.appendChild(pieceClone)
    
    // Only remove highlighting after a delay if it's not the last move
    if (!isLastMove) {
      setTimeout(() => {
        fromSquareEl.classList.remove('move-from')
        toSquareEl.classList.remove('move-to')
      }, 500)
    }
  }

  /**
   * Highlight squares without moving pieces
   * @param fromSquareEl - The source square element
   * @param toSquareEl - The destination square element
   * @param isLastMove - Whether this is the last move in the solution
   */
  highlightSquares(fromSquareEl: Element, toSquareEl: Element, isLastMove: boolean = false) {
    fromSquareEl.classList.add('move-from')
    toSquareEl.classList.add('move-to')
    
    // Only remove highlighting after a delay if it's not the last move
    if (!isLastMove) {
      setTimeout(() => {
        fromSquareEl.classList.remove('move-from')
        toSquareEl.classList.remove('move-to')
      }, 500)
    }
  }
}

// Export a singleton instance
export const solutionReplay = new SolutionReplay()
