import _ from 'underscore'
import Backbone from 'backbone'

import PuzzlePlayer from '../../components/puzzle_player'
import NoMoreLeft from './views/no_more_left'
import PuzzleStats from './views/puzzle_stats'
import SetDifficulty from './views/set_difficulty'
import d from '../../dispatcher'
import { infinityPuzzleSolved } from '../../api/requests'

const apiPath = `/infinity/puzzles`
const fetchThreshold = 5             // fetch more when this many puzzles remain

export default class InfinityMode {
  constructor() {
    new PuzzleStats
    new SetDifficulty
    new NoMoreLeft
    this.listener = _.clone(Backbone.Events)
    this.listenToEvents()
    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      source: apiPath,
    })
  }

  listenToEvents() {
    const config = {}
    this.listener.listenTo(d, `difficulty:selected`, difficulty => {
      d.trigger(
        `source:changed`,
        `${apiPath}?difficulty=${difficulty}`
      )
      d.trigger("difficulty:set", difficulty)
    })
    this.listener.listenTo(d, `config:init`, data => {
      config.difficulty = data.difficulty
      config.numSolved = data.num_solved
      d.trigger(`difficulty:set`, config.difficulty)
      d.trigger(`puzzles_solved:changed`, config.numSolved)
    })
    this.listener.listenTo(d, `puzzle:solved`, puzzle => {
      const puzzleData = {
        puzzle_id: puzzle.id,
        difficulty: config.difficulty
      }
      infinityPuzzleSolved(puzzleData).then(data => {
        if (data.n) {
          d.trigger(`puzzles_solved:changed`, data.n)
        } else {
          config.numSolved++
          d.trigger(`puzzles_solved:changed`, config.numSolved)
        }
      })
    })
    this.listener.listenTo(d, `puzzles:status`, status => {
      const { i, n, lastPuzzleId } = status
      if (i + fetchThreshold > n) {
        d.trigger(
          `source:changed:add`,
          `${apiPath}?difficulty=${config.difficulty}&after_puzzle_id=${lastPuzzleId}`,
        )
      }
    })
  }
}
