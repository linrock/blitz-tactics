import { dispatch, subscribe } from '@blitz/events'

const updateInterval = 50

// Amount of time spent on this round so far
//
export default class Timer {
  private timer?: number
  private startTime: number
  private timerEl: HTMLElement
  private lapsEl: HTMLElement

  get el() {
    return document.querySelector(`.times`)
  }

  constructor() {
    this.timerEl = this.el.querySelector(`.timer`)
    this.lapsEl = this.el.querySelector(`.laps`)
    subscribe({
      'puzzles:start': () => this.startTimer(),
      'puzzles:next': () => this.startTimer(),
      'puzzles:lap': () => this.nextLap(),
    })
  }

  private elapsedTimeMs(): number {
    return ~~(Date.now() - this.startTime)
  }

  private formattedTime(integer: number): string {
    const minutes = ~~( integer / 60 )
    const seconds = integer % 60
    return `${minutes}:${("0" + seconds).slice(-2)}`
  }

  private formattedElapsedTime(): string {
    return this.formattedTime(~~(this.elapsedTimeMs() / 1000))
  }

  private startTimer() {
    if (this.startTime || this.timer) {
      return
    }
    let lastElapsed
    this.startTime = Date.now()
    this.timer = window.setInterval(() => {
      const elapsed = this.formattedElapsedTime()
      if (elapsed !== lastElapsed) {
        lastElapsed = elapsed
        this.timerEl.textContent = elapsed
      }
    }, updateInterval)
  }

  private stopTimer() {
    if (this.timer) {
      clearInterval(this.timer)
      this.timer = undefined
    }
  }

  private nextLap() {
    if (this.elapsedTimeMs() === 0) {
      return
    }
    this.stopTimer()
    const lastLap =`<div>${this.formattedElapsedTime()}</div>`
    this.lapsEl.innerHTML = lastLap + this.lapsEl.innerHTML
    this.notify()
    this.startTime = 0
    this.startTimer()
  }

  private notify() {
    dispatch(`round:complete`, this.elapsedTimeMs())
  }
}
