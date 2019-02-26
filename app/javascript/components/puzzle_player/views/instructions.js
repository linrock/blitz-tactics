// white to move

import Backbone from 'backbone'

import { subscribe } from '../../../store'

export default class Instructions extends Backbone.View {

  get el() {
    return document.querySelector(`.instructions`)
  }

  initialize() {
    subscribe({
      'puzzles:start': () => this.remove(),
      'move:too_slow': () => this.el.classList.add(`smaller`),
      'puzzle:loaded': () => this.el.classList.remove(`invisible`),
      'board:flipped': isFlipped => {
        if (isFlipped) {
          this.el.textContent = `Black to move`
        }
      },
    })
  }
}
