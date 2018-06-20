import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Instructions extends Backbone.View {

  get el() {
    return ".instructions"
  }

  initialize() {
    this.listenTo(d, "move:too_slow", () => {
      this.$el.addClass("smaller")
    })
    this.listenTo(d, "puzzles:start", () => {
      this.$el.fadeOut(50)
    })
  }
}
