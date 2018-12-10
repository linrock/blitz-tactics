import Backbone from 'backbone'

import d from '../../../dispatcher.ts'

const updateInterval = 50

// Amount of time spent on this round so far
//
export default class Timer extends Backbone.View {

  get el() {
    return document.querySelector(`.times`)
  }

  initialize() {
    this.listenForEvents()
    this.timerEl = this.el.querySelector(`.timer`)
    this.lapsEl = this.el.querySelector(`.laps`)
    this.timer = false
  }

  listenForEvents() {
    this.listenTo(d, `puzzles:start`, () => this.startTimer())
    this.listenTo(d, `puzzles:next`, () => this.startTimer())
    this.listenTo(d, `puzzles:lap`, () => this.nextLap())
  }

  elapsedTimeMs() {
    return ~~(Date.now() - this.startTime)
  }

  formattedTime(integer) {
    const minutes = ~~( integer / 60 )
    const seconds = integer % 60
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
      const elapsed = this.formattedElapsedTime()
      if (elapsed !== lastElapsed) {
        lastElapsed = elapsed
        this.timerEl.textContent = elapsed
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
    // this.$laps.prepend(`<div>${this.formattedElapsedTime()}</div>`)
    this.notify()
    this.startTime = false
    this.startTimer()
  }

  notify() {
    d.trigger(`round:complete`, blitz.levelPath, this.elapsedTimeMs())
  }
}
