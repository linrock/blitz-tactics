// onboarding message on first level of repetition mode

import Backbone from 'backbone'

import { subscribe } from '../../../store'

export default class Onboarding extends Backbone.View {

  get el() {
    return document.querySelector(`.onboarding`)
  }

  initialize() {
    if (!this.el) {
      return
    }
    subscribe({
      'puzzles:start': () => this.el.classList.add(`invisible`)
    })
  }
}
