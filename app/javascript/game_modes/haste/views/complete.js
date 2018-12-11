import Backbone from 'backbone'

import d from '../../../dispatcher.ts'

export default class Complete extends Backbone.View {

  get el() {
    return document.querySelector(`.haste-mode`)
  }

  initialize() {
    this.timerEl = this.el.querySelector(`.timers`)
    this.highScoreEl = this.el.querySelector(`.haste-complete`)
    this.listenTo(d, `haste:complete`, data => {
      this.showPersonalBest(data)
    })
  }

  showPersonalBest({ score, best }) {
    this.timerEl.style = `display: none`
    this.highScoreEl.style = ``
    this.highScoreEl.querySelector(`.your-score .score`).textContent = score
    this.highScoreEl.querySelector(`.high-score .score`).textContent = best
    this.highScoreEl.classList.remove(`invisible`)
  }
}
