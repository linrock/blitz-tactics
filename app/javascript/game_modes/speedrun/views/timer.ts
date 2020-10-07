import { dispatch, subscribe, subscribeOnce } from '@blitz/store'
import { formattedTime } from '@blitz/utils'

const updateInterval = 37

// Amount of time spent so far
//
export default class Timer {
  private startTime: number
  private timerInterval: number

  get el(): HTMLElement {
    return document.querySelector(`.current-run .timer`)
  }

  constructor() {
    subscribeOnce(`move:try`, () => this.startTimer())
    subscribe({
      'puzzles:complete': () => this.notifyCompletion()
    })
  }

  private elapsedTimeMilliseconds(): number {
    return Date.now() - this.startTime
  }

  private startTimer() {
    this.el.classList.remove(`stopped`)
    this.startTime = Date.now()
    this.timerInterval = window.setInterval(
      () => this.displayElapsedTime(),
      updateInterval
    )
  }

  private stopTimer() {
    this.el.classList.add(`complete`)
    clearInterval(this.timerInterval)
    this.displayElapsedTime()
  }

  private displayElapsedTime() {
    this.el.textContent = formattedTime(this.elapsedTimeMilliseconds())
  }

  private notifyCompletion() {
    this.stopTimer()
    dispatch(`timer:stopped`, this.elapsedTimeMilliseconds())
  }
}
