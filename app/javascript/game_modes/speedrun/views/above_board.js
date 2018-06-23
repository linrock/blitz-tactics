import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class AboveBoard extends Backbone.View {

  get el() {
    return ".speedrun-mode"
  }

  get template() {
    return `<div class="speedrun-complete">Speedrun complete!</div>`
  }

  initialize() {
    this.listenTo(d, "speedrun:complete", () => {
      this.$el.find(".above-board").html(this.template)
    })
  }
}
