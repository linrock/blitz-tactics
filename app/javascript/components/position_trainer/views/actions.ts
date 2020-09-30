// action buttons under the board - reset position

import Backbone from 'backbone'

import { dispatch } from '@blitz/store'

export default class Actions extends Backbone.View {

  // @ts-ignore
  get el() {
    return document.querySelector('.actions')
  }

  events(): Backbone.EventsHash {
    return {
      'click .restart' : `_resetPosition`
    }
  }

  private _resetPosition() {
    dispatch(`position:reset`)
  }
}
