import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../../dispatcher'

const comboDroppedAfterMs = 7000
const hintDelay = 750

// Solution/hint that shows up after some time
//
export default class PuzzleHint extends Backbone.View {

  get el() {
    return document.querySelector(`.puzzle-hint`)
  }

  get events() {
    return {
      "mousedown .hint-trigger" : `_showHint`,
      "touchstart .hint-trigger" : `_showHint`
    }
  }

  initialize() {
    this.timeout = false
    this.moveEl = this.el.querySelector(`.move`)
    this.buttonEl = this.el.querySelector(`.hint-trigger`)
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, `puzzle:loaded`, current => {
      this.current = current
      this.delayedShowHint()
    })
    this.listenTo(d, `move:make`, () => this.delayedShowHint())
    this.listenTo(d, `timer:stopped`, () => this.clearHintTimer())
  }

  clearHintTimer() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  delayedShowHint() {
    this.clearHintTimer()
    if (!this.el) {
      return
    }
    this.el.classList.add(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    this.moveEl.textContent = ``
    this.timeout = setTimeout(() => {
      d.trigger(`move:too_slow`)
      setTimeout(() => this.showHint(), hintDelay)
    }, comboDroppedAfterMs)
  }

  showHint() {
    const hints = []
    _.each(_.keys(this.current.boardState), move => {
      if (this.current.boardState[move] !== `retry`) {
        hints.push(move)
      }
    })
    this.el.classList.remove(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    this.moveEl.textContent = _.sample(hints)
  }

  _showHint() {
    this.buttonEl.classList.add(`invisible`)
  }
}
