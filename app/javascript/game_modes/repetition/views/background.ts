import { subscribe } from '@blitz/events'

export default class Background {

  get el(): HTMLElement {
    return document.querySelector(`body`)
  }

  constructor() {
    subscribe({
      'level:unlocked': () => this.el.classList.add(`unlocked`)
    })
  }
}
