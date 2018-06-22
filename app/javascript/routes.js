import PositionTrainer from './components/position_trainer'
import PuzzlePlayer from './components/puzzle_player'
import LevelEditor from './components/level_editor'

import RepetitionMode from './game_modes/repetition'
import InfinityMode from './game_modes/infinity'

const routes = {
  "levels#show": RepetitionMode,
  "levels#edit": LevelEditor,
  "puzzles#show": PuzzlePlayer,
  "infinity#index": InfinityMode,
  "static#position": PositionTrainer,
  "positions#show": PositionTrainer,
}

export default routes
