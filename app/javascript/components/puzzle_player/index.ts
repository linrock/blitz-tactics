import { subscribe } from '@blitz/store'
import { trackEvent } from '@blitz/utils'
import ChessgroundBoard from '../chessground_board'
import InteractiveBoard from '../interactive_board'
import MoveStatus from '../move_status'
import ComboCounter from './views/combo_counter'
import Instructions from './views/instructions'
import PuzzleHint from './views/puzzle_hint'
import PuzzleSource, { PuzzleSourceOptions } from './puzzle_source'

import './style.sass'

interface PuzzlePlayerOptions extends PuzzleSourceOptions {
  noHint?: boolean,
  noCounter?: boolean,
  noCombo?: boolean,
  useChessground?: boolean,
}

/** The puzzle player used in the various game modes */
export default class PuzzlePlayer {
  constructor(options: PuzzlePlayerOptions = {}) {
    new PuzzleSource(options)

    // views
    if (options.useChessground) {
      new ChessgroundBoard
      new MoveStatus
    } else {
      new InteractiveBoard(options)
    }
    new Instructions
    if (!options.noCounter) {
      new ComboCounter
    }
    if (!options.noHint) {
      new PuzzleHint
    }

    subscribe({
      'puzzle:solved': puzzle => {
        trackEvent(`puzzle solved`, window.location.pathname, puzzle.id)
      }
    })
  }
}
