// fades out the board when the level is complete

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Modal extends Backbone.View {

  get el() {
    return document.querySelector(`.board-modal-container`)
  }

  initialize() {
    this.listenTo(d, `timer:stopped`, () => {
      this.el.style = ``
      this.el.classList.remove(`invisible`)
    })
  }
}
