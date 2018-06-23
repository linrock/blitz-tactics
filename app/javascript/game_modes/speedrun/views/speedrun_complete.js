import Backbone from 'backbone'

import d from '../../../dispatcher'
import { formattedTime } from '../../../utils'

export default class SpeedrunComplete extends Backbone.View {

  get el() {
    return `.speedrun-mode`
  }

  initialize() {
    this.$aboveBoard = this.$el.find(`.above-board`)
    this.listenTo(d, `speedrun:complete`, data => {
      this.$aboveBoard.addClass(`invisible`)
      setTimeout(() => {
        this.$aboveBoard.html(
          `<div class="speedrun-complete">Speedrun complete!</div>`
        ).removeClass(`invisible`)
      }, 600)
      this.$el.find(`.personal-best-time`)
        .text(formattedTime(data.best))
      this.$el.find(`.personal-best`)
        .removeClass(`invisible`)
    })
  }
}
