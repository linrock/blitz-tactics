import { createApp, Component } from 'vue'

import InfinityMode from './game_modes/infinity'
import RepetitionMode from './game_modes/repetition'
import SpeedrunMode from './game_modes/speedrun/index.vue'
import CountdownMode from './game_modes/countdown/index.vue'
import HasteMode from './game_modes/haste/index.vue'
import ThreeMode from './game_modes/three/index.vue'
import RatedMode from './game_modes/rated'

import CustomizeBoard from './pages/customize_board'
import PositionTrainer from './pages/position_trainer/index.vue'
import PuzzleSet from './pages/puzzle_set'
import PuzzleList from './pages/puzzle_list'
import PuzzlePage from './pages/puzzle_page'

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

  // puzzle sets
  "puzzle_sets#show": () => {
    // TODO wait for a move before mounting the vue app
    // mountVue(PuzzleSet, '.puzzle-set .vue-app-mount')
    PuzzleSet()
  },

  // position trainers
  "pages#position": () => mountVue(PositionTrainer, '.vue-app-mount'),
  "pages#defined_position": () => mountVue(PositionTrainer, '.vue-app-mount'),

  // user profile
  "users#customize_board": () => new CustomizeBoard,
}

export default routes
