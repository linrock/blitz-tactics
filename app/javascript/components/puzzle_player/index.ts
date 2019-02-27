import InteractiveBoard from '../interactive_board'
import ComboCounter from './views/combo_counter'
import Instructions from './views/instructions'
import PuzzleHint from './views/puzzle_hint'
import PuzzleSource from './puzzle_source'
import { subscribe } from '../../store'
import { trackEvent } from '../../utils'

export interface PuzzleSourceOptions {
  shuffle?: boolean,
  loopPuzzles?: boolean,
  mode?: string,
  source?: string,
}

interface PuzzlePlayerOptions extends PuzzleSourceOptions {
  noHint?: boolean,
  noCounter?: boolean,
  noCombo?: boolean,
}

export default class PuzzlePlayer {
  constructor(options: PuzzlePlayerOptions = {}) {
    new PuzzleSource(options)

    // views
    new InteractiveBoard(options)
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
