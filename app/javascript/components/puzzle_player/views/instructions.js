// white to move

import Backbone from 'backbone'

import d from '../../../dispatcher.ts'

export default class Instructions extends Backbone.View {

  get el() {
    return document.querySelector(`.instructions`)
  }

  initialize() {
    this.listenTo(d, `puzzles:start`, () => this.remove())
    this.listenTo(d, `move:too_slow`, () => {
      this.el.classList.add(`smaller`)
    })
  }
}
