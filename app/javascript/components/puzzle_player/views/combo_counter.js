// Indicates # of successful moves in a row

import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class ComboCounter extends Backbone.View {

  get el() {
    return document.querySelector(`.combo-counter`)
  }

  initialize() {
    this.counter = 0
    this.counterEl = this.el.querySelector(`.counter`)
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, `move:success`, () => {
      this.counter += 1
      this.el.classList.remove(`invisible`)
      this.setCounter(this.counter)
    })
    this.listenTo(d, `move:fail`, () => this.droppedCombo())
    this.listenTo(d, `move:too_slow`, () => this.droppedCombo())
  }

  setCounter(counter) {
    this.counterEl.textContent = counter
    this.counterEl.classList.add(`emphasis`)
    setTimeout(() => this.counterEl.classList.remove(`emphasis`), 25)
  }

  droppedCombo() {
    this.counter = 0
    this.el.classList.add(`invisible`)
    // this.counterEl.classList.remove(`large`)
  }
}
