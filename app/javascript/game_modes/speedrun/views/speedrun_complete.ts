import { subscribe } from '@blitz/store'
import { formattedTime } from '@blitz/utils'

export default class SpeedrunComplete {
  private bestTimeEl: HTMLElement
  private playAgainEl: HTMLElement

  get el() {
    return document.querySelector(`.speedrun-mode`)
  }

  constructor() {
    this.bestTimeEl = this.el.querySelector(`.personal-best`)
    this.playAgainEl = this.el.querySelector(`.blue-button`)
    subscribe({
      'speedrun:complete': data => {
        this.renderPersonalBest(data.best)
        this.showPlayAgain()
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

  private showPlayAgain() {
    this.playAgainEl.style.display = `block`
    this.playAgainEl.classList.remove(`invisible`)
  }
}
