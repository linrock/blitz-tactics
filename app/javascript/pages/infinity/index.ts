import { uciToMove } from '@blitz/utils'

// Solution player for recent puzzles - plays directly in miniboards
class SolutionPlayer {
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

    // Update button state
    button.textContent = 'Loading...'
    button.disabled = true
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
        button.textContent = 'No solution'
        button.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      const solutionMoves = this.extractSolutionMoves(solutionLines)
      
      if (solutionMoves.length === 0) {
        console.warn('No solution moves found')
        button.textContent = 'No moves'
        button.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      // Find the miniboard for this puzzle
      const puzzleItem = button.closest('.recent-puzzle-item')
      const miniboard = puzzleItem?.querySelector('.mini-chessboard')
      
      if (!miniboard) {
        console.error('Could not find miniboard for puzzle')
        button.textContent = 'View solution'
        button.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      // Update button state
      button.textContent = 'Playing...'

      // Play the solution
      this.playMovesInMiniboard(miniboard, initialFen, solutionMoves, () => {
        // Reset button when done
        button.textContent = 'View solution'
        button.disabled = false
        this.playingSolutions.delete(puzzleId)
      })

    } catch (error) {
      console.error('Failed to load or parse solution data:', error)
      button.textContent = 'Error'
      button.disabled = false
      this.playingSolutions.delete(puzzleId)
    }
  }

  private playMovesInMiniboard(miniboard: Element, initialFen: string, moves: string[], onComplete: () => void) {
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
        setTimeout(playNextMove, 1000) // 1 second delay between moves
      } else {
        onComplete()
      }
    }
    
    // Start playing moves after a short delay
    setTimeout(playNextMove, 500)
  }

  private animateMoveOnMiniboard(miniboard: Element, moveUci: string) {
    const fromSquare = moveUci.substring(0, 2)
    const toSquare = moveUci.substring(2, 4)
    
    // Get all squares from the miniboard
    const squares = miniboard.querySelectorAll('.square')
    
    // Find squares by position index since the MiniChessboard component 
    // creates squares without data-square attributes
    const fromSquareEl = this.getSquareByPosition(squares, fromSquare)
    const toSquareEl = this.getSquareByPosition(squares, toSquare)
    
    if (!fromSquareEl || !toSquareEl) {
      console.warn(`Could not find squares ${fromSquare} or ${toSquare} on miniboard`)
      return
    }

    // Simulate piece movement by manipulating the pieces
    this.simulatePieceMovement(fromSquareEl, toSquareEl)
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
    
    // Step 1: Highlight the from square and fade out the original piece
    fromSquareEl.classList.add('move-from')
    pieceEl.classList.add('moving-piece')
    
    // Step 2: After a short delay, move the piece to the destination
    setTimeout(() => {
      // Remove piece from original square
      pieceEl.remove()
      
      // Remove any existing piece from destination square
      const existingPiece = toSquareEl.querySelector('.piece')
      if (existingPiece) {
        existingPiece.remove()
      }
      
      // Add the piece to the destination square
      toSquareEl.appendChild(pieceClone)
      toSquareEl.classList.add('move-to')
      
      // Add arrival animation
      pieceClone.classList.add('piece-arrived')
      
      // Step 3: Clean up after animation
      setTimeout(() => {
        fromSquareEl.classList.remove('move-from')
        toSquareEl.classList.remove('move-to')
        pieceClone.classList.remove('piece-arrived')
      }, 600)
      
    }, 200)
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
    // Convert square notation (e.g., "e4") to board index
    // The MiniChessboard creates squares in row-by-row order: a8, b8, c8, ..., h8, a7, b7, ..., h1
    const file = squareId.charAt(0) // 'a' to 'h'
    const rank = parseInt(squareId.charAt(1)) // 1 to 8
    
    // Convert to 0-based indices
    const fileIndex = file.charCodeAt(0) - 'a'.charCodeAt(0) // 0 to 7
    const rankIndex = 8 - rank // 0 to 7 (rank 8 = index 0, rank 1 = index 7)
    
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