// tells user of their progress in the current level

import { dispatch, subscribe } from '@blitz/store'

export default class Progress {
  private nSolved = 0

  get el(): HTMLElement {
    return document.querySelector(`.current-countdown .description`)
  }

  constructor() {
    subscribe({
      'puzzles:status': ({ i }) => {
        this.nSolved = i + 1
        this.updateProgress()
      },
      'timer:stopped': () => {
        dispatch(`timer:complete`, this.nSolved)
      },
    })
  }

  private updateProgress(): void {
    this.el.textContent = `${this.nSolved} puzzles solved`
  }
}
