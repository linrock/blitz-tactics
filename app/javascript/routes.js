import PositionTrainer from './components/position_trainer'
import PuzzlePlayer from './components/puzzle_player'

import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun'

const routes = {
  "puzzles#show": PuzzlePlayer,
  "pages#position": PositionTrainer,
  "pages#defined_position": PositionTrainer,

  // game modes
  "game_modes/speedrun#index": SpeedrunMode,
  "game_modes/infinity#index": InfinityMode,
  "game_modes/repetition#index": RepetitionMode,
}

export default routes
