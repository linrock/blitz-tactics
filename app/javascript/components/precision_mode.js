import PuzzlePlayer from './puzzle_player'
import PrecisionModeView from '../views/precision_mode'
import LevelProgress from '../models/precision_mode/level_progress'
import Notifier from '../models/precision_mode/notifier'

export default class PrecisionMode {
  constructor() {
    // views
    new PuzzlePlayer
    new PrecisionModeView

    // models
    new LevelProgress
    new Notifier
  }
}
