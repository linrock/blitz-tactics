import _ from 'underscore'
import Backbone from 'backbone'

import PuzzlePlayer from '../../components/puzzle_player'
import Instructions from './views/instructions'
import Timer from './views/timer'
import Progress from './views/progress'
import AboveBoard from './views/above_board'
import { speedrunCompleted } from '../../api/requests'
import d from '../../dispatcher'

export default class Speedrun {
  constructor() {
    new Instructions
    new AboveBoard
    new Timer
    new Progress

    this.listener = _.clone(Backbone.Events)
    this.listenToEvents()

    new PuzzlePlayer({
      shuffle: false,
      loopPuzzles: false,
      source: `/speedrun/puzzles`
    })
  }

  listenToEvents() {
    this.listener.listenTo(d, "timer:stopped", elapsedTimeMs => {
      speedrunCompleted(elapsedTimeMs).then(data => {
        d.trigger("speedrun:complete", data)
      })
    })
  }
}
