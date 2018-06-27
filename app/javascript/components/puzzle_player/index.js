import InteractiveBoard from '../interactive_board'
import ComboCounter from './views/combo_counter'
import Instructions from './views/instructions'
import PuzzleHint from './views/puzzle_hint'

import PuzzleSource from './puzzle_source'
// import SoundPlayer from './sound_player'

import Listener from '../../listener'
import { trackEvent } from '../../utils'

export default class PuzzlePlayer {
  constructor(options = {}) {
    new PuzzleSource(options)
    // new SoundPlayer

    // views
    new InteractiveBoard
    new ComboCounter
    new Instructions
    new PuzzleHint

    new Listener({
      'puzzle:solved': puzzle => {
        trackEvent(`puzzle solved`, window.location.pathname, puzzle.id)
      }
    })
  }
}
