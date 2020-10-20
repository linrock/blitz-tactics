import { createApp } from 'vue'

import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun/index.vue'
import CountdownMode from './game_modes/countdown/index.vue'
import HasteMode from './game_modes/haste/index.vue'
import RatedMode from './game_modes/rated'

import CustomizeBoard from './components/customize_board'
import PositionTrainer from './components/position_trainer'
import PuzzlePage from './components/puzzle_page'

interface RouteMap {
  [routeKey: string]: () => void
}

const routes: RouteMap = {
  // game modes
  "game_modes/speedrun#index": () => {
    createApp(SpeedrunMode).mount('.speedrun-mode .vue-app-mount')
  },
  "game_modes/countdown#index": () => {
    createApp(CountdownMode).mount('.countdown-mode .vue-app-mount')
  },
  "game_modes/haste#index": () => {
    createApp(HasteMode).mount('.haste-mode .vue-app-mount')
  },
  "game_modes/infinity#index": () => InfinityMode(),
  "game_modes/repetition#index": () => RepetitionMode(),
  "game_modes/rated#index": () => RatedMode(),

  // individual puzzle pages
  "puzzles#show": () => PuzzlePage(),

  // position trainers
  "pages#position": () => new PositionTrainer,
  "pages#defined_position": () => new PositionTrainer,

  // user profile
  "users#customize_board": () => new CustomizeBoard,
}

export default routes
