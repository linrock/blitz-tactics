// instructions that fade out after you start

import Backbone from 'backbone'

import { subscribeOnce } from '../../../store'

export default class Sidebar extends Backbone.View {

  get el() {
    return document.querySelector(`.countdown-sidebar`)
  }

  initialize() {
    subscribeOnce(`move:try`, () => {
      this.el.querySelector(`.make-a-move`).remove()
      this.el.querySelector(`.timers`).style = ``
    })
  }
}
