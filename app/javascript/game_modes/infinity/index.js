import PuzzlePlayer from '../../components/puzzle_player'
import NoMoreLeft from './views/no_more_left'
import PuzzleStats from './views/puzzle_stats'
import SetDifficulty from './views/set_difficulty'
import Listener from '../../listener.ts'
import { infinityPuzzleSolved } from '../../api/requests'
import d from '../../dispatcher.ts'

const apiPath = `/infinity/puzzles`
const fetchThreshold = 5 // fetch more puzzles when this # puzzles remain

export default class InfinityMode {
  constructor() {
    new PuzzleStats
    new SetDifficulty
    new NoMoreLeft

    this.config = {}
    this.listenForEvents()

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      source: apiPath,
    })
  }

  listenForEvents() {
    new Listener({
      'difficulty:selected': difficulty => {
        d.trigger(
          `source:changed`,
          `${apiPath}?difficulty=${difficulty}`
        )
        d.trigger(`difficulty:set`, difficulty)
      },

      'config:init': data => {
        this.config.difficulty = data.difficulty
        this.config.numSolved = data.num_solved
        d.trigger(`difficulty:set`, this.config.difficulty)
        d.trigger(`puzzles_solved:changed`, this.config.numSolved)
      },

      'puzzle:solved': puzzle => {
        const puzzleData = {
          puzzle_id: puzzle.id,
          difficulty: this.config.difficulty
        }
        infinityPuzzleSolved(puzzleData).then(data => {
          if (data.n) {
            d.trigger(`puzzles_solved:changed`, data.n)
          } else {
            this.config.numSolved++
            d.trigger(`puzzles_solved:changed`, this.config.numSolved)
          }
        })
      },

      'puzzles:status': status => {
        const { i, n, lastPuzzleId } = status
        if (i + fetchThreshold > n) {
          d.trigger(
            `source:changed:add`,
            `${apiPath}?difficulty=${this.config.difficulty}&after_puzzle_id=${lastPuzzleId}`,
          )
        }
      }
    })
  }
}
