import { subscribe } from '../../../store'

// Fastest 5 player round times in the sidebar

export default class HighScores {

  get el() {
    return document.querySelector(`.high-scores`)
  }

  constructor() {
    this.scoresEl = this.el.querySelector(`.scores`)
    if (this.scoresEl.innerText.length > 0) {
      this.showHighScores()
    }
    subscribe({
      'level:high_scores': scores => this.renderScores(scores)
    })
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
