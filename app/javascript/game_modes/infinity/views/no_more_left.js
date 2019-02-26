import Backbone from 'backbone'

import { subscribe, subscribeOnce } from '../../../store'

export default class NoMoreLeft extends Backbone.View {

  get el() {
    return document.querySelector(`.no-more-left`)
  }

  initialize() {
    subscribe({
      'puzzles:complete': () => {
        this.el.classList.remove(`invisible`)
        setTimeout(() => {
          subscribeOnce(`difficulty:set`, () => {
            this.el.classList.add(`invisible`)
          })
        }, 1000)
      }
    })
  }
}
