import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class CountdownComplete extends Backbone.View {

  get el() {
    return document.querySelector(`.countdown-mode`)
  }

  initialize() {
    this.timerEl = this.el.querySelector(`.timers`)
    this.highScoreEl = this.el.querySelector(`.countdown-complete`)
    this.listenTo(d, `countdown:complete`, data => {
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
