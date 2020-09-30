import { dispatch, subscribe, subscribeOnce } from '@blitz/store'
import { formattedTimeSeconds } from '@blitz/utils'

const updateInterval = 100   // timer updates this frequently
const penaltyMs = 30000      // lose this much time per mistake

// Amount of time spent so far
//
export default class Timer {
  private initialTimeMs: number
  private lostTimeMs = 0
  private startTime: number
  private timerInterval: number

  get el(): HTMLElement {
    return document.querySelector(`.current-countdown .timer`)
  }

  constructor() {
    this.initialTimeMs = parseInt(this.el.textContent[0]) * 60 * 1000 + 500
    subscribeOnce(`move:try`, () => this.startTimer())
    subscribe({
      'move:fail': () => this.loseTime(),
      'puzzles:complete': () => this.notifyCompletion(),
    })
  }

  private timeLeftMilliseconds(): number {
    return this.initialTimeMs - (Date.now() - this.startTime) - this.lostTimeMs
  }

  private loseTime() {
    this.lostTimeMs += penaltyMs
    this.el.classList.add(`penalized`)
    setTimeout(() => this.el.classList.remove(`penalized`), 200)
  }

  private startTimer() {
    this.el.classList.remove(`stopped`)
    this.startTime = Date.now()
    this.timerInterval = window.setInterval(() => {
      const timeLeft = this.timeLeftMilliseconds()
      if (timeLeft <= 0) {
        this.stopTimer()
        this.notifyCompletion()
      } else {
        this.displayTimeLeft(formattedTimeSeconds(timeLeft))
      }
    }, updateInterval)
  }

  private stopTimer() {
    this.el.classList.add(`stopped`)
    clearInterval(this.timerInterval)
    this.displayTimeLeft(`0:00`)
  }

  private displayTimeLeft(timeLeftText: string) {
    this.el.textContent = timeLeftText
  }

  private notifyCompletion() {
    dispatch("timer:stopped")
  }
}
