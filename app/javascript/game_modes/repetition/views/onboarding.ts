// onboarding message on first level of repetition mode

import { subscribe, GameEvent } from '@blitz/events'

export default class Onboarding {

  get el() {
    return document.querySelector(`.onboarding`)
  }

  constructor() {
    if (!this.el) {
      return
    }
    subscribe({
      [GameEvent.PUZZLES_START]: () => this.el.classList.add(`invisible`)
    })
  }
}
