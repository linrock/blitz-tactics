import InteractiveBoard from '../../views/interactive_board'
import ComboCounter from './views/combo_counter'
import Instructions from './views/instructions'
import PuzzleCounter from './views/puzzle_counter'
import PuzzleHint from './views/puzzle_hint'

import PuzzleSource from './models/puzzle_source'
import SoundPlayer from './models/sound_player'

export default class PuzzlePlayer {
  constructor() {
    // views
    new InteractiveBoard
    new ComboCounter
    new Instructions
    new PuzzleCounter
    new PuzzleHint

    // models
    new PuzzleSource
    new SoundPlayer
  }
}
