// tells user of their progress in the current level

import { dispatch, subscribe } from '../../../store'

export default class Progress {
  nSolved = 0

  get el() {
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

  updateProgress() {
    this.el.textContent = `${this.nSolved} puzzles solved`
  }
}
