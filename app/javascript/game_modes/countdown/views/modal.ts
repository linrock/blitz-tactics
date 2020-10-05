// fades out the board when the level is complete

import { subscribe } from '@blitz/store'

export default class Modal {

  get el(): HTMLElement {
    return document.querySelector(`.board-modal-container`)
  }

  constructor() {
    subscribe({
      'timer:stopped': () => {
        this.el.style.display = ``
        this.el.classList.remove(`invisible`)
      }
    })
  }
}
