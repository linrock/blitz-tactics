// Indicates # of successful moves in a row

import { subscribe } from '@blitz/events'

export default class ComboCounter {
  private counter = 0
  private counterEl: HTMLElement

  get el(): HTMLElement {
    return document.querySelector(`.combo-counter`)
  }

  constructor() {
    this.counterEl = this.el.querySelector(`.counter`)
    subscribe({
      'move:success': () => {
        this.counter += 1
        this.el.classList.remove(`invisible`)
        this.setCounter(this.counter)
      },
      'move:fail': () => this.droppedCombo(),
      'move:too_slow': () => this.droppedCombo(),
    })
  }

  private setCounter(counter: number): void {
    this.counterEl.textContent = String(counter)
    this.counterEl.classList.add(`emphasis`)
    setTimeout(() => this.counterEl.classList.remove(`emphasis`), 25)
  }

  private droppedCombo(): void {
    this.counter = 0
    if (this.el) {
      this.el.classList.add(`invisible`)
    }
    // this.counterEl.classList.remove(`large`)
  }
}
