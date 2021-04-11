import { subscribe } from '@blitz/events'

// Fastest 5 player round times in the sidebar

export default class HighScores {
  private scoresEl: HTMLElement

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

  private template(playerName: string, time: number): string {
    return `
      <div class="high-score">
        <div class="time">${time}</div>
        <div class="player">
          <a href="/${playerName}">${playerName}</a>
        </div>
      </div>
    `
  }

  private showHighScores() {
    this.el.classList.remove(`invisible`)
  }

  private renderScores(scores: [string, number][]) {
    let html = ``
    scores.forEach(([playerName, time]) => {
      html += this.template(playerName, time)
    })
    this.scoresEl.innerHTML = html
    this.showHighScores()
  }
}
