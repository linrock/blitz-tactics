import { dispatch, subscribe } from '@blitz/events'
import { FEN, PuzzleLines, UciMove } from '@blitz/types'
import { moveToUci, uciToMove } from '@blitz/utils'
import ChessgroundBoard from '../chessground_board'
import MoveStatus from '../move_status'

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
  const fenEl: HTMLInputElement = document.querySelector('.fen')

  // Select FEN input upon click for convenient copying
  fenEl.addEventListener('click', (event) => (event.target as HTMLInputElement).select())

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
  new MoveStatus;

  const instructionsEl: HTMLElement = document.querySelector('.instructions')
  const resetPositionEl: HTMLElement = document.querySelector('.button.restart')

  originalInstructions = instructionsEl.textContent

  subscribe({
    'puzzle:solved': () => {
      instructionsEl.textContent = 'Puzzle solved!'
      instructionsEl.classList.remove('invisible')
      chessgroundBoard.freeze()
    },

    // Handle whenever the player tries a move
    'move:try': move => {
      // Always hide the instructions (White to move) after the player make a move
      instructionsEl.classList.add('invisible')
      const attempt = puzzleStateLines[moveToUci(move)]
      if (attempt === `win`) {
        dispatch(`move:success`)
        dispatch(`puzzle:solved`)
        dispatch(`move:make`, move)
        return
      } else if (attempt === `retry`) {
        dispatch(`move:almost`, move)
        return
      } else if (!attempt) {
        dispatch(`move:fail`, move)
        return
      }
      // the puzzle isn't finished yet if we get here
      dispatch(`move:make`, move)
      dispatch(`move:success`)
      const response = Object.keys(attempt)[0]
      const responseMove = uciToMove(response)
      const puzzleLines: PuzzleLines | 'win' | 'retry' = attempt[response]
      if (puzzleLines === `win`) {
        dispatch(`puzzle:solved`)
      } else {
        dispatch(`move:sound`, move)
        setTimeout(() => {
          dispatch(`move:make`, responseMove, { opponent: true })
          puzzleStateLines = puzzleLines as PuzzleLines
        }, 0)
      }
    },
  })

  let firstMoveT

  // Initializes the board position. Makes initial opponent move if there is one
  const resetPosition = (puzzleMovesData: PuzzleMovesData) => {
    chessgroundBoard.unfreeze()
    clearTimeout(firstMoveT)
    dispatch('fen:set', puzzleMovesData.initial_fen)
    if (puzzleMovesData.initial_move_san) {
      const sanMove = puzzleMovesData.initial_move_san
      firstMoveT = setTimeout(() => {
        dispatch('move:make', sanMove, { opponent: true });
        const instructionsEl: HTMLDivElement = document.querySelector('.instructions')
        if (instructionsEl) {
          instructionsEl.textContent = originalInstructions;
          instructionsEl.classList.remove('invisible')
        }
        firstMoveT = undefined
      }, 500)
    }
  }

  // reset position upon pageload and when clicking "Reset Position"
  resetPosition(initialPuzzleState)
  resetPositionEl.addEventListener('click', () => {
    resetPosition(initialPuzzleState)
    puzzleStateLines = Object.assign({}, initialPuzzleState.lines)
  })
}
