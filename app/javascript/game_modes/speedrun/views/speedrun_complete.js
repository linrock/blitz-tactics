import { subscribe } from '../../../store'
import { formattedTime } from '../../../utils.ts'

export default class SpeedrunComplete {

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

  renderPersonalBest(bestTime) {
    if (!bestTime) {
      return
    }
    const formattedBestTime = formattedTime(parseInt(bestTime, 10))
    this.bestTimeEl.querySelector(`.timer`).textContent = formattedBestTime
    this.bestTimeEl.style.display = `block`
    this.bestTimeEl.classList.remove(`invisible`)
  }

  showPlayAgain() {
    this.playAgainEl.style.display = `block`
    this.playAgainEl.classList.remove(`invisible`)
  }
}
