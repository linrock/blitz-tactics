import PuzzlePlayer from './puzzle_player'
import PuzzlesSolved from '../views/infinity_mode/puzzles_solved'
import SetDifficulty from '../views/infinity_mode/set_difficulty'

export default class InfinityMode {
  constructor() {
    new PuzzlePlayer
    new PuzzlesSolved
    new SetDifficulty
  }
}
