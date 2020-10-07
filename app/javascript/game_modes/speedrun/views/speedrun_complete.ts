import { subscribe } from '@blitz/store'
import { formattedTime } from '@blitz/utils'

export default class SpeedrunComplete {
  private bestTimeEl: HTMLElement
  private playAgainEl: HTMLElement
  private viewPuzzlesEl: HTMLElement

  get el(): HTMLElement {
    return document.querySelector(`.speedrun-mode`)
  }

  constructor() {
    this.bestTimeEl = this.el.querySelector(`.personal-best`)
    this.playAgainEl = this.el.querySelector(`.blue-button`)
    this.viewPuzzlesEl = this.el.querySelector(`.view-puzzles`)
    subscribe({
      'speedrun:complete': data => {
        this.renderPersonalBest(data.best)
        this.playAgainEl.style.display = `block`
        this.playAgainEl.classList.remove(`invisible`)
        this.viewPuzzlesEl.style.display = `block`
        this.viewPuzzlesEl.classList.remove(`invisible`)
      }
    })
  }

  private renderPersonalBest(bestTime: string) {
    if (!bestTime) {
      return
    }
    const formattedBestTime = formattedTime(parseInt(bestTime, 10))
    this.bestTimeEl.querySelector(`.timer`).textContent = formattedBestTime
    this.bestTimeEl.style.display = `block`
    this.bestTimeEl.classList.remove(`invisible`)
  }
}
