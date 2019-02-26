import _ from 'underscore'
import Backbone from 'backbone'

import { dispatch, subscribe, subscribeOnce } from '../../../store'
import { formattedTime } from '../../../utils.ts'

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
    subscribeOnce(`move:try`, () => this.startTimer())
    subscribe({
      'puzzles:complete': () => this.notifyCompletion()
    })
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
    dispatch("timer:stopped", this.elapsedTimeMilliseconds())
  }
}
