import Background from './views/background'
import Chessboard from './views/chessboard'
import ComboCounter from './views/combo_counter'
import Instructions from './views/instructions'
import LevelEditor from './views/level_editor'
import LevelIndicator from './views/level_indicator'
import MainHeader from './views/main_header'
import MiniBoard from './views/mini_board'
import MoveStatus from './views/move_status'
import Onboarding from './views/onboarding'
import PiecePromotionModal from './views/piece_promotion_modal'
import ProgressBar from './views/progress_bar'
import PuzzleCounter from './views/puzzle_counter'
import PuzzleHint from './views/puzzle_hint'
import Timer from './views/timer'

import PositionEditor from './experiments/position_editor'
import PositionTrainer from './experiments/position_trainer'
import PositionCreator from './experiments/position_creator'

import PuzzleSource from './models/puzzle_source'
import Notifier from './models/notifier'
import LevelProgress from './models/level_progress'
import SoundPlayer from './models/sound_player'


const routes = {
  "levels#show": function() {
    initPuzzlePlayer()
    new ProgressBar
    new Timer
    new LevelIndicator
    new Background

    new Notifier
    new LevelProgress
  },
  "levels#edit": function() {
    new LevelEditor
  },
  "puzzles#show": function() {
    initPuzzlePlayer()
  },
  "infinity#index": function() {
    initPuzzlePlayer({ source: '/infinity' })
  },
  "static#positions": function() {
    new PositionCreator
  },
  "static#position": function() {
    initBoardBase()
    new PositionTrainer
  },
  "positions#show": function() {
    initBoardBase()
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

function initBoardBase() {
  new Chessboard
  new MainHeader
  new MoveStatus
  new PiecePromotionModal
}

function initPuzzlePlayer() {
  initBoardBase()

  new ComboCounter
  new Instructions
  new PuzzleCounter
  new PuzzleHint

  new SoundPlayer
  new PuzzleSource
}

export default routes
