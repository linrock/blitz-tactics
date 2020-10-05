import { subscribe } from '@blitz/store'

export default class PuzzleStats {
  private nPuzzlesEl: HTMLElement

  get el() {
    return document.querySelector(`.stats`)
  }

  constructor() {
    this.nPuzzlesEl = this.el.querySelector(`span`)
    subscribe({
      'puzzles_solved:changed': (n: number) => {
        this.nPuzzlesEl.textContent = String(n || 0)
        this.el.classList.remove(`invisible`)
      }
    })
  }
}
