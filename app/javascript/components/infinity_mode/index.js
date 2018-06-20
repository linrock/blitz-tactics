import _ from 'underscore'
import Backbone from 'backbone'

import PuzzlePlayer from '../puzzle_player'
import PuzzlesSolved from './views/puzzles_solved'
import SetDifficulty from './views/set_difficulty'
import d from '../../dispatcher'
import api from '../../api'

export default class InfinityMode {
  constructor() {
    const listener = _.clone(Backbone.Events)
    listener.listenTo(d, "difficulty:selected", difficulty => {
      console.log(`difficulty was selected: ${difficulty}`)
    })

    new PuzzlePlayer
    new PuzzlesSolved
    new SetDifficulty
  }
}
