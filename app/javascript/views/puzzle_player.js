import InteractiveBoard from './interactive_board'
import ComboCounter from './puzzle_player/combo_counter'
import Instructions from './puzzle_player/instructions'
import PuzzleCounter from './puzzle_player/puzzle_counter'
import PuzzleHint from './puzzle_player/puzzle_hint'


export default class PuzzlePlayer {
  constructor() {
    new InteractiveBoard
    new ComboCounter
    new Instructions
    new PuzzleCounter
    new PuzzleHint
  }
}
