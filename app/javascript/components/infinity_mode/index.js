import _ from 'underscore'
import Backbone from 'backbone'

import PuzzlePlayer from '../puzzle_player'
import PuzzlesSolved from './views/puzzles_solved'
import SetDifficulty from './views/set_difficulty'
import d from '../../dispatcher'
import api from '../../api'

export default class InfinityMode {
  constructor() {
    this.listenToEvents()
    new PuzzlePlayer
    new PuzzlesSolved
    new SetDifficulty
  }

  listenToEvents() {
    const listener = _.clone(Backbone.Events)
    listener.listenTo(d, `difficulty:selected`, difficulty => {
      d.trigger(
        `source:changed`,
        `/infinity.json?difficulty=${difficulty}`
      )
    })
  }
}
