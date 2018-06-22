import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../../dispatcher'

const updateInterval = 33

// Amount of time spent so far
//
export default class Timer extends Backbone.View {

  get el() {
    return ".timer"
  }

  initialize() {
    this.listenForEvents()
    this.timerInterval = false
  }

  listenForEvents() {
    this.listenToOnce(d, "move:try", () => this.startTimer())
    this.listenTo(d, "puzzles:complete", () => this.notifyCompletion())
  }

  elapsedTimeMilliseconds() {
    return Date.now() - this.startTime
  }

  formattedTime(milliseconds) {
    const centisecondsStr = ("" + milliseconds % 1000)[0]
    const seconds = ~~( milliseconds / 1000 )
    const minutes = ~~( seconds / 60 )
    return `${minutes}:${("0" + seconds).slice(-2)}.${centisecondsStr}`
  }

  formattedElapsedTime() {
    return this.formattedTime(this.elapsedTimeMilliseconds())
  }

  startTimer() {
    this.$el.removeClass("stopped")
    let lastElapsed
    this.startTime = Date.now()
    this.timerInterval = setInterval(() => {
      let elapsed = this.formattedElapsedTime()
      if (elapsed !== lastElapsed) {
        lastElapsed = elapsed
        this.$el.text(elapsed)
      }
    }, updateInterval)
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
      this.timerInterval = false
    }
  }

  notifyCompletion() {
    d.trigger("timer:stopped", this.elapsedTime())
  }
}
