import PuzzlePlayerView from '../views/puzzle_player'
import PuzzleSource from '../models/puzzle_player/puzzle_source'
import SoundPlayer from '../models/puzzle_player/sound_player'

export default class PuzzlePlayer {
  constructor() {
    new PuzzlePlayerView
    new PuzzleSource
    new SoundPlayer
  }
}
