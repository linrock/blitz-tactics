import { subscribe } from '@blitz/events'

// Level name, next level, etc.
//
export default class LevelIndicator {
  private levelNameEl: HTMLElement
  private nextStageEl: HTMLElement

  get el() {
    return document.querySelector(`.under-board`)
  }

  constructor() {
    this.levelNameEl = this.el.querySelector(`.level-name`)
    this.nextStageEl = this.el.querySelector(`.next-stage`)
    subscribe({
      'puzzles:start': () => {
        this.levelNameEl.classList.add(`faded`)
      },
      'level:unlocked': () => {
        this.levelNameEl.classList.add(`invisible`)
        this.nextStageEl.classList.remove(`invisible`)
      }
    })
  }
}
