// tells user of their progress in the current level

import { subscribe } from '@blitz/store'

export default class Progress {

  get el(): HTMLElement {
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

  private updateProgress(i: number, n: number) {
    this.el.textContent = `${i} of ${n} solved`
  }
}
