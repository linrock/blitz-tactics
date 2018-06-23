import PositionTrainer from './components/position_trainer'
import PuzzlePlayer from './components/puzzle_player'
import LevelEditor from './components/level_editor'

import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun'

const routes = {
  "levels#edit": LevelEditor,
  "puzzles#show": PuzzlePlayer,
  "static#position": PositionTrainer,
  "positions#show": PositionTrainer,

  // game modes
  "game_modes/speedrun#index": SpeedrunMode,
  "game_modes/infinity#index": InfinityMode,
  "game_modes/repetition#index": RepetitionMode,
}

export default routes
