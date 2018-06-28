import Backbone from 'backbone'

import d from '../../../dispatcher.ts'
import { formattedTime } from '../../../utils.ts'

export default class SpeedrunComplete extends Backbone.View {

  get el() {
    return document.querySelector(`.speedrun-mode`)
  }

  get template() {
    return `<div class="speedrun-complete">Speedrun complete!</div>`
  }

  initialize() {
    this.aboveBoardEl = this.el.querySelector(`.above-board`)
    this.bestTimeEl = this.el.querySelector(`.personal-best`)
    this.listenTo(d, `speedrun:complete`, data => {
      this.showSpeedrunComplete()
      this.showPersonalBest(data.best)
    })
  }

  showSpeedrunComplete() {
    this.aboveBoardEl.classList.add(`invisible`)
    setTimeout(() => {
      this.aboveBoardEl.innerHTML = this.template
      this.aboveBoardEl.classList.remove(`invisible`)
    }, 600)
  }

  showPersonalBest(bestTime) {
    if (!bestTime) {
      return
    }
    const formattedBestTime = formattedTime(parseInt(bestTime, 10))
    this.bestTimeEl.style = `display: block`
    this.bestTimeEl.querySelector(`.timer`).textContent = formattedBestTime
    this.bestTimeEl.classList.remove(`invisible`)
  }
}
