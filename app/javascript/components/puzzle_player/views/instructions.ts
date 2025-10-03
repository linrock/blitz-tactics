// white to move

import { subscribeOnce, subscribe, GameEvent } from '@blitz/events'

export default class Instructions {

  get el(): HTMLElement {
    return document.querySelector(`.instructions`)
  }

  constructor() {
    console.log('Instructions: Component created, el:', this.el)
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
    subscribe({
      [GameEvent.PUZZLES_START]: () => {
        console.log('Instructions: Received puzzles:start, hiding instructions, el:', this.el)
        this.el.classList.add('invisible')
      },
      [GameEvent.INSTRUCTIONS_SET]: (text) => {
        console.log('Instructions: Setting text to:', text)
        this.el.textContent = text
        this.el.classList.remove('invisible')
      }
    })
  }
}
