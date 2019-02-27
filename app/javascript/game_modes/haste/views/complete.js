// show your current high scores at the end of a haste run

import { subscribe } from '../../../store'

export default class Complete {

  get el() {
    return document.querySelector(`.haste-mode`)
  }

  constructor() {
    this.timerEl = this.el.querySelector(`.timers`)
    this.highScoreEl = this.el.querySelector(`.haste-complete`)
    this.highScoresEl = this.el.querySelector(`.recent-high-scores`)
    this.highScoresListEl = this.highScoresEl.querySelector(`.list`)
    subscribe({
      'haste:complete': data => {
        this.timerEl.style = `display: none`
        this.showPersonalBest(data)
        this.showHighScores(data.high_scores)
      }
    })
  }

  highScoreTemplate(playerName, score) {
    return `
      <div class="high-score">
        <div class="score">${score}</div>
        <div class="player-name">${playerName}</div>
      </div>
    `
  }

  showPersonalBest({ score, best }) {
    this.highScoreEl.style = ``
    this.highScoreEl.querySelector(`.your-score .score`).textContent = score
    this.highScoreEl.querySelector(`.high-score .score`).textContent = best
    this.highScoreEl.classList.remove(`invisible`)
  }

  showHighScores(scores) {
    if (!scores || scores.length < 3) {
      return
    }
    let html = ``
    scores.forEach(([playerName, score]) => {
      html += this.highScoreTemplate(playerName, score)
    })
    this.highScoresListEl.innerHTML = html
    this.highScoresEl.style = ``
  }
}
