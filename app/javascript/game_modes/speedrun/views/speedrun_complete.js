import Backbone from 'backbone'

import d from '../../../dispatcher'
import { formattedTime } from '../../../utils'

export default class SpeedrunComplete extends Backbone.View {

  get el() {
    return `.speedrun-mode`
  }

  get template() {
    return `<div class="speedrun-complete">Speedrun complete!</div>`
  }

  initialize() {
    this.$aboveBoard = this.$(`.above-board`)
    this.$pb = this.$(`.personal-best`)
    this.listenTo(d, `speedrun:complete`, data => {
      this.showSpeedrunComplete()
      this.showPersonalBest(data.best)
    })
  }

  showSpeedrunComplete() {
    this.$aboveBoard.addClass(`invisible`)
    setTimeout(() => {
      this.$aboveBoard.html(this.template).removeClass(`invisible`)
    }, 600)
  }

  showPersonalBest(bestTime) {
    if (bestTime) {
      this.$pb.show().find(`.timer`)
        .text(formattedTime(parseInt(bestTime, 10)))
      this.$pb.removeClass(`invisible`)
    }
  }
}
