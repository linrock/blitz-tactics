import InteractiveBoard from '@blitz/components/interactive_board'
import { dispatch, subscribe, subscribeOnce } from '@blitz/store'
import { FEN, UciMove } from '@blitz/types'
import { moveToUci, uciToMove } from '@blitz/utils'

import './style.sass'

// The `puzzle_data` field in the puzzle data expected from the page
interface PuzzleMovesData {
  fen: FEN,
  initial_move: {
    uci: UciMove,
    san: string,
  },
  lines: any,
}

// This is expected to be rendered in the page upon pageload
interface PuzzleData {
  id: number,
  metadata: any,
  puzzle_data: PuzzleMovesData,
}

const resetPosition = (puzzleMovesData: PuzzleMovesData) => {
  // Initialize the board position. Make initial opponent move if there is one
  dispatch('fen:set', puzzleMovesData.fen)
  if (puzzleMovesData.initial_move) {
    const uciMove = uciToMove(puzzleMovesData.initial_move.uci)
    console.log(`trying move: ${JSON.stringify(uciMove)}`)
    setTimeout(() => {
      dispatch('move:make', uciMove, { opponent: true });
      const instructionsEl: HTMLDivElement = document.querySelector('.instructions')
      if (instructionsEl) {
        instructionsEl.classList.remove('invisible')
      }
    }, 500);
  }
}

/** Initialize an interactive chessboard for this one puzzle */
const newChessboardFromPuzzleMovesData = (puzzleMovesData: PuzzleMovesData) => {
  new InteractiveBoard
  const initialPuzzleState = Object.assign({}, puzzleMovesData)
  let puzzleStateLines = Object.assign({}, puzzleMovesData.lines)

  const instructionsEl: HTMLElement = document.querySelector('.instructions')
  const resetPositionEl: HTMLElement = document.querySelector('.button.restart')

  subscribe({
    // Handle whenever the player tries a move
    'move:try': move => {
      const attempt = puzzleStateLines[moveToUci(move)]
      if (attempt === `win`) {
        dispatch(`move:success`)
        dispatch(`puzzle:solved`)
        dispatch(`move:make`, move)
        return
      } else if (attempt === `retry`) {
        dispatch(`move:almost`, move)
        return
      }
      if (!attempt) {
        dispatch(`move:fail`, move)
        return
      }
      dispatch(`move:make`, move)
      dispatch(`move:success`)
      const response = Object.keys(attempt)[0]
      const responseMove = uciToMove(response)
      if (attempt[response] === `win`) {
        console.log('win!')
        dispatch(`puzzle:solved`)
        dispatch(`move:make`, responseMove, { opponent: true })
      } else {
        dispatch(`move:sound`, move)
        setTimeout(() => {
          dispatch(`move:make`, responseMove, { opponent: true })
          puzzleStateLines = attempt[response]
        }, 0)
      }
    },
  })

  // Hide the instructions (White to move) after the player makes the first move
  subscribeOnce('move:try', () => instructionsEl.remove())

  resetPosition(initialPuzzleState)

  resetPositionEl.addEventListener('click', () => {
    resetPosition(initialPuzzleState)
    puzzleStateLines = Object.assign({}, initialPuzzleState.lines)
  })
}

export default () => {
  console.log("Initializing puzzle page")
  const puzzleJsonDataEl: HTMLScriptElement = document.querySelector("#puzzle-data")
  const puzzleData: PuzzleData = JSON.parse(puzzleJsonDataEl.innerText)
  console.dir(puzzleData)

  newChessboardFromPuzzleMovesData(puzzleData.puzzle_data)
}