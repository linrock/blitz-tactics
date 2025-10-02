import { dispatch, subscribe, GameEvent } from '@blitz/events'
import { FEN, PuzzleLines, UciMove } from '@blitz/types'
import { moveToUci, uciToMove } from '@blitz/utils'

import ChessgroundBoard from '@blitz/components/chessground_board'
import ChessboardResizer from '@blitz/components/puzzle_player/views/chessboard_resizer'
import MoveStatus from '@blitz/components/move_status'
import './style.sass'

// The `puzzle_data` field in the puzzle data expected from the page
interface PuzzleMovesData {
  initial_fen: FEN,
  initial_move_san: string,
  initial_move_uci: UciMove,
  lines: PuzzleLines,
}

// This is expected to be rendered in the page upon pageload
interface PuzzleData {
  id: number,
  metadata: any,
  puzzle_data: PuzzleMovesData,
}

let originalInstructions: string;

export default () => {
  
  const puzzleJsonDataEl: HTMLScriptElement = document.querySelector("#puzzle-data")

  // Select FEN input upon click for convenient copying
  const fenEl: HTMLInputElement = document.querySelector('.fen')
  if (fenEl) {
    fenEl.addEventListener('click', (event) => (event.target as HTMLInputElement).select())
  }

  // Toggle "Report puzzle" section when clicking the button
  const reportPuzzleBtnEl: HTMLElement = document.querySelector('.report-puzzle')
  if (reportPuzzleBtnEl) {
    reportPuzzleBtnEl.addEventListener('click', () => {
      reportPuzzleBtnEl.style.display = 'none'

      const reportPuzzleFormEl: HTMLElement = document.querySelector('.puzzle-report-form')
      reportPuzzleFormEl.style.display = 'block'

      const reportPuzzleTextareaEl = reportPuzzleFormEl.querySelector('textarea')
      reportPuzzleTextareaEl.focus()

      document.querySelector('.cancel-puzzle-report').addEventListener('click', () => {
        reportPuzzleFormEl.style.display = 'none'
        reportPuzzleTextareaEl.value = ''
        reportPuzzleBtnEl.style.display = ''
      })
    })
  }

  // Initialize a chessground board for this one puzzle
  const puzzleData: PuzzleData = JSON.parse(puzzleJsonDataEl.innerText)
  const puzzleMovesData: PuzzleMovesData = puzzleData.puzzle_data
  const initialPuzzleState = Object.assign({}, puzzleMovesData)
  const fen = puzzleData.puzzle_data.initial_fen
  let puzzleStateLines = Object.assign({}, puzzleMovesData.lines)
  console.dir(puzzleData)

  const chessgroundBoard = new ChessgroundBoard({ fen });
  new ChessboardResizer;
  new MoveStatus;

  const instructionsEl: HTMLElement = document.querySelector('.instructions')
  const resetPositionEl: HTMLElement = document.querySelector('.button.restart')
  const showSolutionEl: HTMLElement = document.querySelector('.show-solution')


  originalInstructions = instructionsEl.textContent

  subscribe({
    [GameEvent.PUZZLE_SOLVED]: () => {
      instructionsEl.textContent = 'Puzzle solved!'
      instructionsEl.classList.remove('invisible')
      chessgroundBoard.freeze()
    },

    // Handle whenever the player tries a move
    [GameEvent.MOVE_TRY]: move => {
      // Always hide the instructions (White to move) after the player make a move
      instructionsEl.classList.add('invisible')
      const attempt = puzzleStateLines[moveToUci(move)]
      if (attempt === `win`) {
        dispatch(GameEvent.MOVE_SUCCESS)
        dispatch(GameEvent.PUZZLE_SOLVED)
        dispatch(GameEvent.MOVE_MAKE, move)
        return
      } else if (attempt === `retry`) {
        dispatch(GameEvent.MOVE_ALMOST, move)
        return
      } else if (!attempt) {
        dispatch(GameEvent.MOVE_FAIL, move)
        return
      }
      // the puzzle isn't finished yet if we get here
      dispatch(GameEvent.MOVE_MAKE, move)
      dispatch(GameEvent.MOVE_SUCCESS)
      const response = Object.keys(attempt)[0]
      const responseMove = uciToMove(response)
      const puzzleLines: PuzzleLines | 'win' | 'retry' = attempt[response]
      if (puzzleLines === `win`) {
        dispatch(GameEvent.PUZZLE_SOLVED)
      } else {
        dispatch(GameEvent.MOVE_SOUND, move)
        setTimeout(() => {
          dispatch(GameEvent.MOVE_MAKE, responseMove, { opponent: true })
          puzzleStateLines = puzzleLines as PuzzleLines
        }, 0)
      }
    },
  })

  let firstMoveT
  let solutionTimeouts: number[] = [] // Track solution playback timeouts

  // Initializes the board position. Makes initial opponent move if there is one
  const resetPosition = (puzzleMovesData: PuzzleMovesData) => {
    chessgroundBoard.unfreeze()
    clearTimeout(firstMoveT)
    
    // Clear any pending solution playback timeouts
    solutionTimeouts.forEach(timeoutId => clearTimeout(timeoutId))
    solutionTimeouts = []
    
    // Reset the "Show solution" button state
    if (showSolutionEl) {
      showSolutionEl.textContent = 'Show solution'
      showSolutionEl.disabled = false
    }
    
    dispatch(GameEvent.FEN_SET, puzzleMovesData.initial_fen)
    let firstMove
    if (puzzleMovesData.initial_move_san) {
      firstMove = puzzleMovesData.initial_move_san
    } else {
      firstMove = uciToMove(puzzleMovesData.initial_move_uci)
    }
    firstMoveT = setTimeout(() => {
      dispatch(GameEvent.MOVE_MAKE, firstMove, { opponent: true });
      const instructionsEl: HTMLDivElement = document.querySelector('.instructions')
      if (instructionsEl) {
        instructionsEl.textContent = originalInstructions;
        instructionsEl.classList.remove('invisible')
      }
      firstMoveT = undefined
    }, 500)
  }

  // Extract all moves from the puzzle lines tree
  const extractSolutionMoves = (lines: PuzzleLines): string[] => {
    const moves: string[] = []
    
    const traverse = (currentLines: PuzzleLines | 'win' | 'retry'): void => {
      if (currentLines === 'win' || currentLines === 'retry') {
        return
      }
      
      // Get the first key from the current level (the main solution line)
      const keys = Object.keys(currentLines)
      if (keys.length > 0) {
        const move = keys[0]
        moves.push(move)
        
        // Recursively traverse the next level
        traverse(currentLines[move])
      }
    }
    
    traverse(lines)
    return moves
  }

  // Play the solution moves with 0.7 second delays, continuing from current position
  const playSolution = () => {
    
    // Extract all solution moves
    const solutionMoves = extractSolutionMoves(initialPuzzleState.lines)
    
    // Check if we have any solution moves
    if (solutionMoves.length === 0) {
      instructionsEl.textContent = 'No solution moves found'
      instructionsEl.classList.remove('invisible')
      return
    }
    
    // Disable the button during playback
    showSolutionEl.textContent = 'Playing solution...'
    showSolutionEl.disabled = true
    
    // Play each solution move with 0.7 second delays, starting immediately from current position
    solutionMoves.forEach((moveUci, index) => {
      const delay = 500 + (index * 700) // Start after 0.5s, then 0.7s between each move
      const timeoutId = setTimeout(() => {
        // Mark the last move as an opponent move so it gets highlighted
        const isLastMove = index === solutionMoves.length - 1
        dispatch(GameEvent.MOVE_MAKE, uciToMove(moveUci), { opponent: isLastMove })
        
        // If this is the last move, re-enable the button
        if (isLastMove) {
          const finalTimeoutId = setTimeout(() => {
            showSolutionEl.textContent = 'Show solution'
            showSolutionEl.disabled = false
            instructionsEl.textContent = 'Solution complete!'
            instructionsEl.classList.remove('invisible')
          }, 500)
          solutionTimeouts.push(finalTimeoutId)
        }
      }, delay)
      solutionTimeouts.push(timeoutId)
    })
  }

  // reset position upon pageload and when clicking "Reset Position"
  resetPosition(initialPuzzleState)
  resetPositionEl.addEventListener('click', () => {
    resetPosition(initialPuzzleState)
    puzzleStateLines = Object.assign({}, initialPuzzleState.lines)
  })

  // Show solution when clicking "Show solution" - use event delegation
  document.addEventListener('click', (event) => {
    const target = event.target as HTMLElement
    if (target && target.classList.contains('show-solution')) {
      event.preventDefault()
      playSolution()
    }
  })

  // Also try direct event listener as backup
  if (showSolutionEl) {
    showSolutionEl.addEventListener('click', () => {
      playSolution()
    })
  }
}
