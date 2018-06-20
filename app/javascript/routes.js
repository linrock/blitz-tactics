import PositionTrainer from './components/position_trainer'
import PrecisionMode from './components/precision_mode'
import PuzzlePlayer from './components/puzzle_player'

import LevelEditor from './views/level_editor'
import PositionCreator from './views/position_creator'

const routes = {
  "levels#show": PrecisionMode,
  "levels#edit": LevelEditor,
  "puzzles#show": PuzzlePlayer,
  "infinity#index": PuzzlePlayer,
  "static#positions": PositionCreator,
  "static#position": PositionTrainer,
  "positions#show": PositionTrainer,
}

export default routes
