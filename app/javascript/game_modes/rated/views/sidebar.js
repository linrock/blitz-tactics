// instructions that fade out after you start

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Sidebar extends Backbone.View {

  get el() {
    return document.querySelector(`.rated-sidebar`)
  }

  initialize() {
    this.listenToOnce(d, `move:try`, () => {
      this.el.querySelector(`.instructions`).remove()
      // this.el.querySelector(`.timers`).style = ``
    })
  }
}
