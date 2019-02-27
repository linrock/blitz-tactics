// fades out the board when the level is complete

import { subscribe } from '../../../store'

export default class Modal {

  get el() {
    return document.querySelector(`.board-modal-container`)
  }

  constructor() {
    subscribe({
      'timer:stopped': () => {
        this.el.style = ``
        this.el.classList.remove(`invisible`)
      }
    })
  }
}
