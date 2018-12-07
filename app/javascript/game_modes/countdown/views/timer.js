import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../../dispatcher.ts'
import { formattedTimeSeconds } from '../../../utils.ts'

const updateInterval = 100   // timer updates this frequently
const penaltyMs = 30000      // lose this much time per mistake

// Amount of time spent so far
//
export default class Timer extends Backbone.View {

  get el() {
    return document.querySelector(`.current-countdown .timer`)
  }

  initialize() {
    this.initialTimeMs = parseInt(this.el.textContent[0]) * 60 * 1000 + 500
    this.lostTimeMs = 0
    this.timerInterval = false
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenToOnce(d, `move:try`, () => this.startTimer())
    this.listenTo(d, `move:fail`, () => this.loseTime())
    this.listenTo(d, `puzzles:complete`, () => this.notifyCompletion())
  }

  timeLeftMilliseconds() {
    return this.initialTimeMs - (Date.now() - this.startTime) - this.lostTimeMs
  }

  loseTime() {
    this.lostTimeMs += penaltyMs
    this.el.classList.add(`penalized`)
    setTimeout(() => this.el.classList.remove(`penalized`), 200)
  }

  startTimer() {
    this.el.classList.remove(`stopped`)
    this.startTime = Date.now()
    this.timerInterval = setInterval(() => {
      const timeLeft = this.timeLeftMilliseconds()
      if (timeLeft <= 0) {
        this.stopTimer()
        this.notifyCompletion()
      } else {
        this.displayTimeLeft(formattedTimeSeconds(timeLeft))
      }
    }, updateInterval)
  }

  stopTimer() {
    this.el.classList.add(`stopped`)
    clearInterval(this.timerInterval)
    this.displayTimeLeft(`0:00`)
  }

  displayTimeLeft(timeLeftText) {
    this.el.textContent = timeLeftText
  }

  notifyCompletion() {
    d.trigger("timer:stopped")
  }
}
