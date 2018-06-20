import PuzzlePlayer from './components/puzzle_player'
import PrecisionMode from './components/precision_mode'
import InteractiveBoard from './views/interactive_board'

import Chessboard from './views/chessboard'
import LevelEditor from './views/level_editor'

import PositionEditor from './experiments/position_editor'
import PositionTrainer from './experiments/position_trainer'
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
    new InteractiveBoard
    new PositionTrainer
  },
  "positions#show": function() {
    new InteractiveBoard
    new PositionTrainer
  },
  "positions#new": function() {
    new Chessboard
    new PositionEditor
  },
  "positions#edit": function() {
    new Chessboard
    new PositionEditor
  }
}

export default routes
