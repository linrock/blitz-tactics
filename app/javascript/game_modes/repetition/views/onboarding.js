// onboarding message on first level of repetition mode

import Backbone from 'backbone'

import d from '../../../dispatcher.ts'

export default class Onboarding extends Backbone.View {

  get el() {
    return document.querySelector(`.onboarding`)
  }

  initialize() {
    if (!this.el) {
      return
    }
    this.listenTo(d, `puzzles:start`, () => {
      this.el.classList.add(`invisible`)
    })
  }
}
