// fades out the board when the level is complete

import Backbone from 'backbone'

import { subscribe } from '../../../store'

export default class Modal extends Backbone.View {

  get el() {
    return document.querySelector(`.board-modal-container`)
  }

  initialize() {
    subscribe({
      'timer:stopped': () => {
        this.el.style = ``
        this.el.classList.remove(`invisible`)
      }
    })
  }
}
