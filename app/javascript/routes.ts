import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun'
import CountdownMode from './game_modes/countdown'
import HasteMode from './game_modes/haste'
import RatedMode from './game_modes/rated'

import CustomizeBoard from './components/customize_board'
import PositionTrainer from './components/position_trainer'
import PuzzlePage from './components/puzzle_page'

interface RouteMap {
  [routeKey: string]: { new(): void } | (() => void)
}

const routes: RouteMap = {
  // game modes
  "game_modes/speedrun#index": SpeedrunMode,
  "game_modes/countdown#index": CountdownMode,
  "game_modes/haste#index": HasteMode,
  "game_modes/infinity#index": InfinityMode,
  "game_modes/repetition#index": RepetitionMode,
  "game_modes/rated#index": RatedMode,

  // puzzle pages
  "puzzles#show": PuzzlePage,

  // position trainers
  "pages#position": PositionTrainer,
  "pages#defined_position": PositionTrainer,

  // user profile
  "users#customize_board": CustomizeBoard,
}

export default routes
