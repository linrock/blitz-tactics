import Backbone from 'backbone'

import d from '../../../dispatcher'

// Fastest 5 player round times in the sidebar

export default class HighScores extends Backbone.View {

  get el() {
    return document.querySelector(`.high-scores`)
  }

  initialize() {
    this.scoresEl = this.el.querySelector(`.scores`)
    if (this.scoresEl.innerText.length > 0) {
      this.showHighScores()
    }
    this.listenTo(d, `level:high_scores`, scores => this.renderScores(scores))
  }

  template(playerName, time) {
    return `
      <div class="high-score">
        <div class="time">${time}</div>
        <div class="player">
          <a href="/${playerName}">${playerName}</a>
        </div>
      </div>
    `
  }

  showHighScores() {
    this.el.classList.remove(`invisible`)
  }

  renderScores(scores) {
    let html = ``
    scores.forEach(([playerName, time]) => {
      html += this.template(playerName, time)
    })
    this.scoresEl.innerHTML = html
    this.showHighScores()
  }
}
