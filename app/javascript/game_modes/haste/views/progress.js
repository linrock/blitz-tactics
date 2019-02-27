// tells user of their progress in the current level

import { dispatch, subscribe } from '../../../store'

export default class Progress {
  nSolved = 0

  get el() {
    return document.querySelector(`.current-progress .n-solved`)
  }

  constructor() {
    subscribe({
      'puzzles:status': ({ i }) => {
        this.nSolved = i + 1
        this.el.textContent = `${this.nSolved} puzzles solved`
      },
      'timer:stopped': () => {
        dispatch(`timer:complete`, this.nSolved)
      }
    })
  }
}
