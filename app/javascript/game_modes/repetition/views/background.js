import { subscribe } from '../../../store'

export default class Background {

  get el() {
    return document.querySelector(`body`)
  }

  constructor() {
    subscribe({
      'level:unlocked': () => this.el.classList.add(`unlocked`)
    })
  }
}
