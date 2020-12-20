// white to move

import { subscribeOnce } from '@blitz/events'

export default class Instructions {

  get el(): HTMLElement {
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
    subscribeOnce('puzzles:start', () => this.el.classList.add('invisible'))
  }
}
