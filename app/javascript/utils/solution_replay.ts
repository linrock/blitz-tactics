/**
 * Reusable solution replay utility for miniboards
 * Extracted from working implementations in three/haste/countdown game modes
 */

import MiniChessboard from '@blitz/components/mini_chessboard'

export class SolutionReplay {
  private originalBoardStates = new Map()
  private playedBoards = new Set<string>() // Track which boards have had solutions played

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
    console.log('replaySolutionOnMiniboardWithCallback called with:', { miniboardEl, solutionLines })
    
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

    console.log('Initial FEN:', initialFen)
    console.log('Miniboard element:', miniboardEl)
    console.log('Miniboard innerHTML:', miniboardEl.innerHTML)

    // Check if this board has already had a solution played
    const boardId = miniboardEl.getAttribute('data-puzzle-id') || miniboardEl.id || 'unknown'
    const hasBeenPlayed = this.playedBoards.has(boardId)
    
    console.log('Board ID:', boardId, 'Has been played:', hasBeenPlayed)

    // Play the solution moves with callback when complete
    this.playMovesInMiniboardWithCallback(miniboardEl, initialFen, solutionMoves, onComplete, hasBeenPlayed)
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
    console.log('Total moves found:', moves.length)
    
    // Log each move with its position in the sequence
    moves.forEach((move, index) => {
      console.log(`Move ${index + 1}: ${move}`)
    })
    
    return moves
  }

  /**
   * Play moves on a miniboard
   * @param miniboard - The miniboard DOM element
   * @param initialFen - The initial FEN position (not used anymore)
   * @param moves - Array of UCI moves to play
   */
  playMovesInMiniboard(miniboard: HTMLElement, initialFen: string, moves: string[]) {
    if (moves.length === 0) {
      return
    }

    // Don't reset the board - start from current position
    console.log('Starting solution replay from current board position (no callback)')
    
    let currentMoveIndex = 0
    
    const playNextMove = () => {
      if (currentMoveIndex < moves.length) {
        // Clear any existing highlights before the first solution move
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
    
    // Start playing moves immediately from current position
    playNextMove()
  }

  /**
   * Play moves on a miniboard with callback when complete
   * @param miniboard - The miniboard DOM element
   * @param initialFen - The initial FEN position
   * @param moves - Array of UCI moves to play
   * @param onComplete - Callback function when all moves are complete
   * @param hasBeenPlayed - Whether this board has already had a solution played
   */
  playMovesInMiniboardWithCallback(miniboard: HTMLElement, initialFen: string, moves: string[], onComplete: () => void, hasBeenPlayed: boolean = false) {
    console.log('playMovesInMiniboardWithCallback called with:', { miniboard, initialFen, moves, hasBeenPlayed })
    
    if (moves.length === 0) {
      console.log('No moves to play, calling onComplete')
      onComplete()
      return
    }

    const boardId = miniboard.getAttribute('data-puzzle-id') || miniboard.id || 'unknown'
    
    let currentMoveIndex = 0
    
    const playNextMove = () => {
      console.log(`Playing move ${currentMoveIndex + 1}/${moves.length}: ${moves[currentMoveIndex]}`)
      
      if (currentMoveIndex < moves.length) {
        // Clear any existing highlights before the first solution move
        if (currentMoveIndex === 0) {
          console.log('Clearing existing highlights')
          this.clearExistingHighlights(miniboard)
        }
        
        const moveUci = moves[currentMoveIndex]
        const isLastMove = currentMoveIndex === moves.length - 1
        console.log(`Animating move: ${moveUci}, isLastMove: ${isLastMove}`)
        this.animateMoveOnMiniboard(miniboard, moveUci, isLastMove)
        currentMoveIndex++
        
        setTimeout(playNextMove, 700) // 0.7 second delay between moves
      } else {
        // All moves completed, mark this board as played and call the callback
        console.log('All moves completed, marking board as played')
        this.playedBoards.add(boardId)
        onComplete()
      }
    }
    
    if (hasBeenPlayed) {
      // Board has been played before, reset to initial position first
      console.log('Board has been played before, resetting to initial position')
      this.resetBoardToOriginalPosition(miniboard).then(() => {
        console.log('Starting move playback after reset')
        playNextMove()
      })
    } else {
      // First time playing, start from current position
      console.log('First time playing solution, starting from current position')
      playNextMove()
    }
  }

  /**
   * Reset miniboard to original position
   * @param miniboard - The miniboard DOM element
   * @returns Promise that resolves when reset is complete
   */
  resetBoardToOriginalPosition(miniboard: HTMLElement): Promise<void> {
    return new Promise((resolve) => {
      const originalFen = miniboard.getAttribute('data-fen')
      const originalMove = miniboard.getAttribute('data-initial-move')
      const flip = miniboard.getAttribute('data-flip')
      
      console.log('resetBoardToOriginalPosition called with:', { originalFen, originalMove, flip })
      
      if (!originalFen) {
        console.warn('No original FEN data found for reset')
        resolve()
        return
      }

      console.log('Recreating miniboard with original FEN:', originalFen)
      
      // Clear existing highlights first
      this.clearExistingHighlights(miniboard)
      
      // Create miniboard at original FEN (without initial move animation)
      const newMiniboard = new MiniChessboard({
        el: miniboard,
        fen: originalFen,
        // Don't pass initialMove here - we'll apply it manually
        flip: flip === 'true'
      })
      
      // Store the new instance
      ;(miniboard as any).miniboardInstance = newMiniboard
      console.log('New miniboard created, applying initial move immediately...')
      
      // If there's an initial move, apply it immediately (no animation)
      if (originalMove && originalMove !== '') {
        const cjs = (newMiniboard as any).cjs
        if (cjs) {
          try {
            const moveResult = cjs.move({
              from: originalMove.slice(0, 2),
              to: originalMove.slice(2, 4),
              promotion: originalMove.length > 4 ? originalMove[4] : undefined
            })
            
            if (moveResult) {
              // Highlight the move
              const highlightSquare = (newMiniboard as any).highlightSquare
              if (highlightSquare) {
                highlightSquare.call(newMiniboard, moveResult.from, 'move-from')
                highlightSquare.call(newMiniboard, moveResult.to, 'move-to')
              }
              
              // Render at the position after the move
              const renderFen = (newMiniboard as any).renderFen
              if (renderFen) {
                renderFen.call(newMiniboard, cjs.fen())
              }
              
              console.log('Initial move applied immediately, board at position after setup move')
            }
          } catch (error) {
            console.warn('Failed to apply initial move:', error)
          }
        }
      }
      
      // Shorter wait time since we're not animating the initial move
      setTimeout(() => {
        console.log('Miniboard reset complete, ready for solution replay')
        resolve()
      }, 100)
    })
  }


  /**
   * Store the original board state
   * @param miniboard - The miniboard DOM element
   * @param fen - The FEN string
   */
  storeOriginalBoardState(miniboard: HTMLElement, fen: string) {
    console.log('storeOriginalBoardState called for FEN:', fen)
    
    // Get squares from cg-wrap if it exists
    let squares = miniboard.querySelectorAll('.square')
    if (squares.length === 0) {
      const cgWrap = miniboard.querySelector('.cg-wrap')
      if (cgWrap) {
        squares = cgWrap.querySelectorAll('.square')
        console.log('Found squares in cg-wrap:', squares.length)
      }
    }
    
    const pieces: any[] = []
    
    squares.forEach((square, index) => {
      // Try multiple selectors to find pieces
      let piece = square.querySelector('.piece')
      if (!piece) {
        piece = square.querySelector('piece')
      }
      if (!piece) {
        piece = square.firstElementChild
      }
      
      if (piece) {
        // Clone the piece to store its exact state
        const pieceClone = piece.cloneNode(true)
        pieces.push({ squareIndex: index, piece: pieceClone })
        console.log(`Stored piece at square ${index}:`, pieceClone)
      }
    })
    
    console.log(`Stored ${pieces.length} pieces for FEN:`, fen)
    
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
    console.log('restoreFromStoredState called for FEN:', fen)
    
    const storedState = this.originalBoardStates.get(fen)
    if (!storedState) {
      console.warn('No stored state found for FEN:', fen)
      return
    }

    // Get squares from cg-wrap if it exists
    let squares = miniboard.querySelectorAll('.square')
    if (squares.length === 0) {
      const cgWrap = miniboard.querySelector('.cg-wrap')
      if (cgWrap) {
        squares = cgWrap.querySelectorAll('.square')
        console.log('Found squares in cg-wrap for restoration:', squares.length)
      }
    }

    console.log('Clearing all current pieces from', squares.length, 'squares')

    // Clear all current pieces using multiple selectors
    squares.forEach(square => {
      // Remove pieces with .piece class
      const piecesWithClass = square.querySelectorAll('.piece')
      piecesWithClass.forEach(piece => piece.remove())
      
      // Remove piece tags
      const pieceTags = square.querySelectorAll('piece')
      pieceTags.forEach(piece => piece.remove())
      
      // Remove any first child that might be a piece
      if (square.firstElementChild) {
        square.firstElementChild.remove()
      }
    })

    console.log('Restoring', storedState.pieces.length, 'original pieces')

    // Restore original pieces
    storedState.pieces.forEach(({ squareIndex, piece }: any) => {
      const targetSquare = squares[squareIndex]
      if (targetSquare) {
        // Clone the piece again to avoid DOM node conflicts
        const pieceClone = piece.cloneNode(true)
        targetSquare.appendChild(pieceClone)
        console.log(`Restored piece at square ${squareIndex}:`, pieceClone)
      }
    })

    // Clear any existing highlights first
    this.clearExistingHighlights(miniboard)

    // Restore initial move highlighting if it exists
    if (originalMove && originalMove !== '') {
      setTimeout(() => {
        this.highlightInitialMove(miniboard, originalMove)
        console.log('Restored initial move highlighting:', originalMove)
      }, 100)
    }
    
    console.log('Board restoration completed for FEN:', fen)
  }

  /**
   * Highlight the initial move on the miniboard
   * @param miniboard - The miniboard DOM element
   * @param moveUci - The move UCI string
   */
  highlightInitialMove(miniboard: HTMLElement, moveUci: string) {
    const fromSquare = moveUci.substring(0, 2)
    const toSquare = moveUci.substring(2, 4)
    
    // Get squares from cg-wrap if it exists
    let squares = miniboard.querySelectorAll('.square')
    if (squares.length === 0) {
      const cgWrap = miniboard.querySelector('.cg-wrap')
      if (cgWrap) {
        squares = cgWrap.querySelectorAll('.square')
      }
    }
    
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
    // Get squares from cg-wrap if it exists
    let squares = miniboard.querySelectorAll('.square')
    if (squares.length === 0) {
      const cgWrap = miniboard.querySelector('.cg-wrap')
      if (cgWrap) {
        squares = cgWrap.querySelectorAll('.square')
      }
    }
    
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
    
    console.log(`animateMoveOnMiniboard called: ${moveUci} (${fromSquare} -> ${toSquare})`)
    console.log('Miniboard element:', miniboard)
    console.log('Miniboard innerHTML:', miniboard.innerHTML)
    
    // Get all squares from the miniboard
    // The MiniChessboard creates a cg-wrap element, so we need to look inside it
    let squares = miniboard.querySelectorAll('.square')
    
    // If no squares found, try looking inside cg-wrap
    if (squares.length === 0) {
      const cgWrap = miniboard.querySelector('.cg-wrap')
      if (cgWrap) {
        squares = cgWrap.querySelectorAll('.square')
        console.log(`Found ${squares.length} squares inside cg-wrap`)
      }
    }
    
    console.log(`Found ${squares.length} squares on miniboard`)
    
    if (squares.length === 0) {
      console.error('No squares found on miniboard!')
      console.log('Miniboard structure:', miniboard.outerHTML)
      console.log('cg-wrap structure:', miniboard.querySelector('.cg-wrap')?.outerHTML)
      return
    }
    
    // Find squares by position index
    const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
    const toSquareEl = this.getSquareByPosition(squares, toSquare)
    
    if (!fromSquareEl || !toSquareEl) {
      console.warn(`Could not find squares ${fromSquare} or ${toSquare} on miniboard`)
      console.log('Available squares:', Array.from(squares).map((sq, i) => ({ index: i, element: sq, classes: sq.className })))
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
    console.log('simulatePieceMovement called with:', { fromSquareEl, toSquareEl, isLastMove })
    console.log('From square classes:', fromSquareEl.className)
    console.log('To square classes:', toSquareEl.className)
    
    // Get the piece from the 'from' square
    // Try multiple selectors to find the piece
    let pieceEl = fromSquareEl.querySelector('.piece')
    if (!pieceEl) {
      // Try finding any element that looks like a piece
      pieceEl = fromSquareEl.querySelector('piece')
    }
    if (!pieceEl) {
      // Try finding any child element
      pieceEl = fromSquareEl.firstElementChild
    }
    
    console.log('Found piece element:', pieceEl)
    console.log('From square innerHTML:', fromSquareEl.innerHTML)
    console.log('To square innerHTML before move:', toSquareEl.innerHTML)
    console.log('From square children:', Array.from(fromSquareEl.children))
    
    if (!pieceEl) {
      // If no piece, just highlight squares
      console.log('No piece found, just highlighting squares')
      this.highlightSquares(fromSquareEl, toSquareEl, isLastMove)
      return
    }

    // Clone the piece element
    const pieceClone = pieceEl.cloneNode(true) as Element
    console.log('Cloned piece:', pieceClone)
    console.log('Cloned piece classes:', pieceClone.className)
    
    // Highlight squares and move the piece
    fromSquareEl.classList.add('move-from')
    toSquareEl.classList.add('move-to')
    
    // Remove the original piece
    pieceEl.remove()
    console.log('Original piece removed')
    
    // Remove any existing piece from destination square
    let existingPiece = toSquareEl.querySelector('.piece')
    if (!existingPiece) {
      existingPiece = toSquareEl.querySelector('piece')
    }
    if (!existingPiece) {
      existingPiece = toSquareEl.firstElementChild
    }
    
    if (existingPiece) {
      console.log('Removing existing piece from destination:', existingPiece)
      existingPiece.remove()
    }
    
    // Add the cloned piece to the destination square
    toSquareEl.appendChild(pieceClone)
    console.log('Cloned piece added to destination')
    console.log('To square innerHTML after move:', toSquareEl.innerHTML)
    
    // Verify the move was successful
    let newPiece = toSquareEl.querySelector('.piece')
    if (!newPiece) {
      newPiece = toSquareEl.querySelector('piece')
    }
    if (!newPiece) {
      newPiece = toSquareEl.firstElementChild
    }
    console.log('New piece in destination:', newPiece)
    
    // Only remove highlighting after a delay if it's not the last move
    if (!isLastMove) {
      setTimeout(() => {
        fromSquareEl.classList.remove('move-from')
        toSquareEl.classList.remove('move-to')
        console.log('Highlights removed')
      }, 500)
    } else {
      console.log('Last move - keeping highlights')
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
