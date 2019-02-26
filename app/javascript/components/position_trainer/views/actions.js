// action buttons under the board - reset position

import { dispatch } from '../../../store'

export default class Actions extends Backbone.View {

  get el() {
    return `.actions`
  }

  get events() {
    return {
      'click .restart' : `_resetPosition`
    }
  }

  _resetPosition() {
    dispatch(`position:reset`)
  }
}
