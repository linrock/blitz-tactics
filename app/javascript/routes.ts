import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun'
import CountdownMode from './game_modes/countdown'

import PositionTrainer from './components/position_trainer'

interface RouteMap {
  [routeKey: string]: { new(): void }
}

const routes: RouteMap = {
  // game modes
  "game_modes/speedrun#index": SpeedrunMode,
  "game_modes/countdown#index": CountdownMode,
  "game_modes/infinity#index": InfinityMode,
  "game_modes/repetition#index": RepetitionMode,

  // position trainers
  "pages#position": PositionTrainer,
  "pages#defined_position": PositionTrainer,
}

export default routes
