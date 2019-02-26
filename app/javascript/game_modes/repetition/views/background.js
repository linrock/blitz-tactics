import Backbone from 'backbone'

import { subscribe } from '../../../store'

export default class Background extends Backbone.View {

  get el() {
    return document.querySelector(`body`)
  }

  initialize() {
    subscribe({
      'level:unlocked': () => this.el.classList.add(`unlocked`)
    })
  }
}
