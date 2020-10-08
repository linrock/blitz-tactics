import InteractiveBoard from '@blitz/components/interactive_board'
import { dispatch, subscribe } from '@blitz/store'
import { FEN, PuzzleLines, UciMove } from '@blitz/types'
import { moveToUci, uciToMove } from '@blitz/utils'

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

const resetPosition = (puzzleMovesData: PuzzleMovesData) => {
  // Initialize the board position. Make initial opponent move if there is one
  dispatch('fen:set', puzzleMovesData.initial_fen)
  if (puzzleMovesData.initial_move_uci) {
    const sanMove = puzzleMovesData.initial_move_san
    console.log(`initial opponent move: ${(sanMove)}`)
    setTimeout(() => {
      dispatch('move:make', sanMove, { opponent: true });
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
  dispatch(`board:flipped`, !!puzzleMovesData.initial_fen.match(/ w /))

  const instructionsEl: HTMLElement = document.querySelector('.instructions')
  const resetPositionEl: HTMLElement = document.querySelector('.button.restart')

  subscribe({
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
      dispatch(`move:make`, move)
      dispatch(`move:success`)
      const response = Object.keys(attempt)[0]
      const responseMove = uciToMove(response)
      const puzzleLines: PuzzleLines | 'win' | 'retry' = attempt[response]
      if (puzzleLines === `win`) {
        console.log('win!')
        dispatch(`puzzle:solved`)
        dispatch(`move:make`, responseMove, { opponent: true })
      } else {
        dispatch(`move:sound`, move)
        setTimeout(() => {
          dispatch(`move:make`, responseMove, { opponent: true })
          puzzleStateLines = puzzleLines as PuzzleLines
        }, 0)
      }
    },
  })

  resetPosition(initialPuzzleState)

  resetPositionEl.addEventListener('click', () => {
    resetPosition(initialPuzzleState)
    puzzleStateLines = Object.assign({}, initialPuzzleState.lines)
  })
}

export default () => {
  const puzzleJsonDataEl: HTMLScriptElement = document.querySelector("#puzzle-data")
  const fenEl: HTMLInputElement = document.querySelector('.fen')

  // Select FEN input upon click
  fenEl.addEventListener('click', (event) => (event.target as HTMLInputElement).select())

  const puzzleData: PuzzleData = JSON.parse(puzzleJsonDataEl.innerText)
  // console.dir(puzzleData)
  newChessboardFromPuzzleMovesData(puzzleData.puzzle_data)
}