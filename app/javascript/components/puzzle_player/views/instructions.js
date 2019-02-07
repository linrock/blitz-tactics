// white to move

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Instructions extends Backbone.View {

  get el() {
    return document.querySelector(`.instructions`)
  }

  initialize() {
    this.listenTo(d, `puzzles:start`, () => this.remove())
    this.listenTo(d, `board:flipped`, isFlipped => {
      if (isFlipped) {
        this.el.textContent = `Black to move`
      }
    })
    this.listenTo(d, `move:too_slow`, () => {
      this.el.classList.add(`smaller`)
    })
    this.listenTo(d, `puzzle:loaded`, () => {
      this.el.classList.remove(`invisible`)
    })
  }
}
