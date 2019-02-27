import { subscribe } from '../../../store'

export default class PuzzleStats {

  get el() {
    return document.querySelector(`.stats`)
  }

  constructor() {
    this.nPuzzlesEl = this.el.querySelector(`span`)
    subscribe({
      'puzzles_solved:changed': n => {
        this.nPuzzlesEl.textContent = n || 0
        this.el.classList.remove(`invisible`)
      }
    })
  }
}
