// instructions that fade out after you start

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Instructions extends Backbone.View {

  get el() {
    return ".speedrun-instructions"
  }

  initialize() {
    this.listenTo(d, "move:try", () => this.$el.addClass("invisible"))
  }
}
