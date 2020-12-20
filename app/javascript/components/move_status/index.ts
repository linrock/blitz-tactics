import { subscribe } from '@blitz/events'

const perfectTiming = 2500
const greatTiming = 5000

/** Encouragement when successful, discouragement when making a wrong move */
export default class MoveStatus {
  private timeSinceSuccess: number

  get el() {
    return document.querySelector(`.move-status`)
  }

  constructor() {
    this.timeSinceSuccess = Date.now()
    subscribe({
      'move:success': () => this.renderSuccess(),
      'move:fail': () => this.renderFailure(),
      'move:almost': () => this.renderAlmost(),
    })
  }

  private renderSuccess() {
    const time = Date.now()
    const tDiff = time - this.timeSinceSuccess
    if (tDiff < perfectTiming) {
      this.renderPerfect()
    } else if (tDiff < greatTiming) {
      this.renderGreat()
    } else {
      this.renderGood()
    }
    this.timeSinceSuccess = time
  }

  private renderFailure() {
    this.renderFadingMessage(`<div class="fail">Try Again</div>`)
  }

  private renderAlmost() {
    this.renderFadingMessage(`<div class="almost">Almost</div>`)
  }

  private renderPerfect() {
    this.renderFadingMessage(`<div class="perfect">Perfect!</div>`)
  }

  private renderGreat() {
    this.renderFadingMessage(`<div class="great">Great!</div>`)
  }

  private renderGood() {
    this.renderFadingMessage(`<div class="good">Good!</div>`)
  }

  private renderFadingMessage(html: string) {
    this.el.classList.remove(`fade-out`)
    this.el.innerHTML = html
    setTimeout(() => this.el.classList.add(`fade-out`), 50)
  }
}
