import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class NoMoreLeft extends Backbone.View {

  get el() {
    return document.querySelector(`.no-more-left`)
  }

  initialize() {
    this.listenTo(d, `puzzles:complete`, () => {
      this.el.classList.remove(`invisible`)
      setTimeout(() => {
        this.listenToOnce(d, `difficulty:set`, () => {
          this.el.classList.add(`invisible`)
        })
      }, 1000)
    })
  }
}
