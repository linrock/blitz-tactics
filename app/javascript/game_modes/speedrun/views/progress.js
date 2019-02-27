// tells user of their progress in the current level

import { subscribe } from '../../../store'

export default class Progress {

  get el() {
    return document.querySelector(`.current-run .description`)
  }

  constructor() {
    subscribe({
      'puzzles:fetched': puzzles => {
        this.updateProgress(0, puzzles.length)
      },
      'puzzles:status': ({ i , n }) => {
        this.updateProgress(i + 1, n)
      },
    })
  }

  updateProgress(i, n) {
    this.el.textContent = `${i} of ${n} solved`
  }
}
