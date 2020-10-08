import { subscribe } from '@blitz/store'

export default class CountdownComplete {
  private timerEl: HTMLElement
  private highScoreEl: HTMLElement

  get el(): HTMLElement {
    return document.querySelector(`.countdown-mode`)
  }

  constructor() {
    subscribe({
      'countdown:complete': data => this.showPersonalBest(data)
    })
  }

  private showPersonalBest({ score, best }) {
    this.timerEl = this.el.querySelector(`.timers`)
    this.highScoreEl = this.el.querySelector(`.countdown-complete`)
    this.timerEl.style.display = `none`
    this.highScoreEl.style.display = ``
    this.highScoreEl.querySelector(`.your-score .score`).textContent = score
    this.highScoreEl.querySelector(`.high-score .score`).textContent = best
    this.highScoreEl.classList.remove(`invisible`)
  }
}
