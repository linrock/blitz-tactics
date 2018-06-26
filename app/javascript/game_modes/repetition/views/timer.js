import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../../dispatcher'

const updateInterval = 50

// Amount of time spent on this round so far
//
export default class Timer extends Backbone.View {

  get el() {
    return ".times"
  }

  initialize() {
    this.listenForEvents()
    this.$timer = this.$(".timer")
    this.$laps = this.$(".laps")
    this.timer = false
  }

  listenForEvents() {
    this.listenTo(d, "puzzles:start", _.bind(this.startTimer, this))
    this.listenTo(d, "puzzles:next", _.bind(this.startTimer, this))
    this.listenTo(d, "puzzles:lap", _.bind(this.nextLap, this))
  }

  elapsedTimeMs() {
    return ~~(Date.now() - this.startTime)
  }

  formattedTime(integer) {
    let minutes = ~~( integer / 60 )
    let seconds = integer % 60
    return `${minutes}:${("0" + seconds).slice(-2)}`
  }

  formattedElapsedTime() {
    return this.formattedTime(~~(this.elapsedTimeMs() / 1000))
  }

  startTimer() {
    if (this.startTime || this.timer) {
      return
    }
    let lastElapsed
    this.startTime = Date.now()
    this.timer = setInterval(() => {
      let elapsed = this.formattedElapsedTime()
      if (elapsed != lastElapsed) {
        lastElapsed = elapsed
        this.$timer.text(elapsed)
      }
    }, updateInterval)
  }

  stopTimer() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = false
    }
  }

  nextLap() {
    if (this.elapsedTimeMs() === 0) {
      return
    }
    this.stopTimer()
    this.$laps.prepend(`<div>${this.formattedElapsedTime()}</div>`)
    this.notify()
    this.startTime = false
    this.startTimer()
  }

  notify() {
    d.trigger("round:complete", blitz.levelPath, this.elapsedTimeMs())
  }
}
