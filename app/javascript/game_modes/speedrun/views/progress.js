// tells user of their progress in the current level

import Backbone from 'backbone'
import d from '../../../dispatcher'

export default class Progress extends Backbone.View {

  get el() {
    return ".progress"
  }

  initialize() {
    this.listenTo(d, "puzzles:status", status => {
      const { i, n } = status
      this.$el.text(`${i + 1} of ${n} puzzles solved`)
    })
  }
}
