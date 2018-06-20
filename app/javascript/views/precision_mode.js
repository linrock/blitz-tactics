import Background from './precision_mode/background'
import LevelIndicator from './precision_mode/level_indicator'
import Onboarding from './precision_mode/onboarding'
import ProgressBar from './precision_mode/progress_bar'
import Timer from './precision_mode/timer'

export default class PrecisionMode {
  constructor() {
    new Background
    new LevelIndicator
    new ProgressBar
    new Timer
  }
}
