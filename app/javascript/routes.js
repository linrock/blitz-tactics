import PositionTrainer from './components/position_trainer'
import PrecisionMode from './components/precision_mode'
import PuzzlePlayer from './components/puzzle_player'

import Chessboard from './views/chessboard'
import LevelEditor from './views/level_editor'

import PositionCreator from './experiments/position_creator'


const routes = {
  "levels#show": function() {
    new PrecisionMode
  },
  "levels#edit": function() {
    new LevelEditor
  },
  "puzzles#show": function() {
    new PuzzlePlayer
  },
  "infinity#index": function() {
    new PuzzlePlayer
  },
  "static#positions": function() {
    new PositionCreator
  },
  "static#position": function() {
    new PositionTrainer
  },
  "positions#show": function() {
    new PositionTrainer
  },
}

export default routes
