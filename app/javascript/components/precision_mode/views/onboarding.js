// onboarding message on first level of precision mode

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Onboarding extends Backbone.View {

  get el() {
    return ".onboarding"
  }

  initialize() {
    this.listenTo(d, "puzzles:start", () => {
      this.$el.addClass("invisible")
    })
  }
}
