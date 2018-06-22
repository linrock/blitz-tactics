import InfinityMode from './components/infinity_mode'
import PositionTrainer from './components/position_trainer'
import RepetitionMode from './components/repetition_mode'
import PuzzlePlayer from './components/puzzle_player'
import LevelEditor from './components/level_editor'

const routes = {
  "levels#show": RepetitionMode,
  "levels#edit": LevelEditor,
  "puzzles#show": PuzzlePlayer,
  "infinity#index": InfinityMode,
  "static#position": PositionTrainer,
  "positions#show": PositionTrainer,
}

export default routes
