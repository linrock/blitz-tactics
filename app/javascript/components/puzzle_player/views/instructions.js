// white to move

import Backbone from 'backbone'

import { subscribe, subscribeOnce } from '../../../store'

export default class Instructions extends Backbone.View {

  get el() {
    return document.querySelector(`.instructions`)
  }

  initialize() {
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
    subscribeOnce('puzzles:start', () => this.remove())
  }
}
