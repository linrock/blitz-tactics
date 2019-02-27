// Indicates # of successful moves in a row

import { subscribe } from '../../../store'

export default class ComboCounter {

  get el() {
    return document.querySelector(`.combo-counter`)
  }

  constructor() {
    this.counter = 0
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

  setCounter(counter) {
    this.counterEl.textContent = counter
    this.counterEl.classList.add(`emphasis`)
    setTimeout(() => this.counterEl.classList.remove(`emphasis`), 25)
  }

  droppedCombo() {
    this.counter = 0
    if (this.el) {
      this.el.classList.add(`invisible`)
    }
    // this.counterEl.classList.remove(`large`)
  }
}
