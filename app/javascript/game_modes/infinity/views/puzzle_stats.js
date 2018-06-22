import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class PuzzleStats extends Backbone.View {

  get el() {
    return ".stats"
  }

  initialize() {
    this.$n = this.$el.find("span")
    this.listenTo(d, "puzzles_solved:changed", n => {
      this.$n.text(n || 0)
      this.$el.removeClass("invisible")
    })
  }
}
