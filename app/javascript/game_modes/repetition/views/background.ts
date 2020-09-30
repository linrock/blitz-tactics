import { subscribe } from '@blitz/store'

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
