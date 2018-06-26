import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../../dispatcher'
import { formattedTime } from '../../../utils'

const updateInterval = 37

// Amount of time spent so far
//
export default class Timer extends Backbone.View {

  get el() {
    return document.querySelector(`.current-run .timer`)
  }

  initialize() {
    this.listenForEvents()
    this.timerInterval = false
  }

  listenForEvents() {
    this.listenToOnce(d, `move:try`, () => this.startTimer())
    this.listenTo(d, `puzzles:complete`, () => this.notifyCompletion())
  }

  elapsedTimeMilliseconds() {
    return Date.now() - this.startTime
  }

  startTimer() {
    this.el.classList.remove(`stopped`)
    this.startTime = Date.now()
    this.timerInterval = setInterval(() => this.displayElapsedTime(), updateInterval)
  }

  stopTimer() {
    this.el.classList.add(`complete`)
    clearInterval(this.timerInterval)
    this.displayElapsedTime()
  }

  displayElapsedTime() {
    this.el.textContent = formattedTime(this.elapsedTimeMilliseconds())
  }

  notifyCompletion() {
    this.stopTimer()
    d.trigger("timer:stopped", this.elapsedTimeMilliseconds())
  }
}
