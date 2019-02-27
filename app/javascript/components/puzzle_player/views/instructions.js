// white to move

import { subscribe, subscribeOnce } from '../../../store'

export default class Instructions {

  get el() {
    return document.querySelector(`.instructions`)
  }

  constructor() {
    subscribeOnce('move:too_slow', () => {
      this.el.classList.add(`smaller`)
    })
    subscribeOnce('puzzle:loaded', () => {
      this.el.classList.remove(`invisible`)
    })
    subscribeOnce('board:flipped', isFlipped => {
      if (isFlipped) {
        this.el.textContent = `Black to move`
      }
    })
    subscribeOnce('puzzles:start', () => this.el.remove())
  }
}
