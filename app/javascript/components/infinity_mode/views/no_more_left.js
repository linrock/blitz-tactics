import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class NoMoreLeft extends Backbone.View {
  get el() {
    return ".no-more-left"
  }

  initialize() {
    this.listenTo(d, "puzzles:complete", () => {
      this.$el.removeClass("invisible")
      setTimeout(() => {
        this.listenToOnce(d, "difficulty:set", difficulty => {
          this.$el.addClass("invisible")
        })
      }, 1000)
    })
  }
}
