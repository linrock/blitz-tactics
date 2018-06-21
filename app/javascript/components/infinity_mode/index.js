import _ from 'underscore'
import Backbone from 'backbone'

import PuzzlePlayer from '../puzzle_player'
import PuzzleStats from './views/puzzle_stats'
import SetDifficulty from './views/set_difficulty'
import d from '../../dispatcher'
import { infinityPuzzleSolved } from '../../api/requests'

export default class InfinityMode {
  constructor() {
    new PuzzleStats
    new SetDifficulty
    this.listenToEvents()
    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      source: `/infinity.json`,
    })
  }

  listenToEvents() {
    const config = {}
    const listener = _.clone(Backbone.Events)
    listener.listenTo(d, `difficulty:selected`, difficulty => {
      d.trigger(
        `source:changed`,
        `/infinity.json?difficulty=${difficulty}`
      )
      d.trigger("difficulty:set", difficulty)
    })
    listener.listenTo(d, `config:init`, data => {
      config.difficulty = data.difficulty
      config.numSolved = data.num_solved
      d.trigger(`difficulty:set`, config.difficulty)
      d.trigger(`puzzles_solved:changed`, config.numSolved)
    })
    listener.listenTo(d, `puzzle:solved`, puzzle => {
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
  }
}
