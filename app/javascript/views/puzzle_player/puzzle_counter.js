import Backbone from 'backbone'

import d from '../../dispatcher'

// Number of puzzles solved in this round
//
export default class PuzzleCounter extends Backbone.View {

  get el() {
    return ".puzzle-counter"
  }

  initialize() {
    this.i = 0
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, "puzzles:next", () => {
      this.incCounter()
    })
  }

  incCounter() {
    this.$el.text(this.i++)
  }
}
