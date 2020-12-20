import { createApp, Component } from 'vue'

import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun/index.vue'
import CountdownMode from './game_modes/countdown/index.vue'
import HasteMode from './game_modes/haste/index.vue'
import ThreeMode from './game_modes/three/index.vue'
import RatedMode from './game_modes/rated'

import CustomizeBoard from './components/customize_board'
import PositionTrainer from './components/position_trainer/index.vue'
import PuzzlePage from './components/puzzle_page'
import PuzzleList from './components/puzzle_list'

interface RouteMap {
  [routeKey: string]: () => void
}

const mountVue = (component: Component, selector: string) => {
  createApp(component).mount(selector)
}

const routes: RouteMap = {
  // game modes
  "game_modes/speedrun#index": () => mountVue(SpeedrunMode, '.speedrun-mode .vue-app-mount'),
  "game_modes/countdown#index": () => mountVue(CountdownMode, '.countdown-mode .vue-app-mount'),
  "game_modes/haste#index": () => mountVue(HasteMode, '.haste-mode .vue-app-mount'),
  "game_modes/three#index": () => mountVue(ThreeMode, '.three-mode .vue-app-mount'),
  "game_modes/infinity#index": () => InfinityMode(),
  "game_modes/repetition#index": () => RepetitionMode(),
  "game_modes/rated#index": () => RatedMode(),

  // individual puzzle pages
  "puzzles#show": () => PuzzlePage(),

  // lists of puzzles (ex. after finishing a game)
  "puzzles#index": () => PuzzleList(),

  // position trainers
  "pages#position": () => mountVue(PositionTrainer, '.vue-app-mount'),
  "pages#defined_position": () => mountVue(PositionTrainer, '.vue-app-mount'),

  // user profile
  "users#customize_board": () => new CustomizeBoard,
}

export default routes
