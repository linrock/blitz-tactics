import InteractiveBoard from '@blitz/components/interactive_board'
import { dispatch } from '@blitz/store'
import { FEN, UciMove } from '@blitz/types'
import { uciToMove } from '@blitz/utils'

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

const newChessboardFromPuzzleMovesData = (puzzleMovesData: PuzzleMovesData) => {
  new InteractiveBoard
  dispatch('fen:set', puzzleMovesData.fen)
  if (puzzleMovesData.initial_move) {
    const uciMove = uciToMove(puzzleMovesData.initial_move.uci)
    console.log(`trying move: ${JSON.stringify(uciMove)}`)
    setTimeout(() => {
      dispatch('move:make', uciMove, { opponent: true });
      (document.querySelector('.instructions') as HTMLDivElement).classList.remove('invisible')
    }, 500);
  }
}

export default () => {
  console.log("Initializing puzzle page")
  const puzzleJsonDataEl: HTMLScriptElement = document.querySelector("#puzzle-data")
  const puzzleData: PuzzleData = JSON.parse(puzzleJsonDataEl.innerText)
  console.dir(puzzleData)

  newChessboardFromPuzzleMovesData(puzzleData.puzzle_data)
}