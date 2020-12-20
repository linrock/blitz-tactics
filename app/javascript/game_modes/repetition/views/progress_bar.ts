// bar under main header showing how close you are to the next level

import { subscribe } from '@blitz/events'

export default class ProgressBar {
  private progressEl: HTMLElement
  private complete = false

  get el(): HTMLElement {
    return document.querySelector(`.progress-bar`)
  }

  constructor() {
    this.progressEl = this.el.querySelector(`.progress`)
    subscribe({
      'progress:update': percent => {
        if (!this.complete) {
          this.updateProgress(percent)
        }
      }
    })
  }

  updateProgress(percent) {
    this.progressEl.style.width = `${percent}%`
    if (percent >= 100) {
      this.progressEl.classList.add(`complete`)
      this.complete = true
    }
  }
}
