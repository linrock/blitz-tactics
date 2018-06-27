import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun'
import PositionTrainer from './components/position_trainer'

const routes = {
  // game modes
  "game_modes/speedrun#index": SpeedrunMode,
  "game_modes/infinity#index": InfinityMode,
  "game_modes/repetition#index": RepetitionMode,

  // position trainers
  "pages#position": PositionTrainer,
  "pages#defined_position": PositionTrainer,
}

export default routes
