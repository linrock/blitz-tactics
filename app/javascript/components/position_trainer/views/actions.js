// action buttons under the board - reset position

import d from '../../../dispatcher'

export default class Actions extends Backbone.View {

  get el() {
    return ".actions"
  }

  get events() {
    return {
      "click .restart" : "_resetPosition"
    }
  }

  _resetPosition() {
    d.trigger("position:reset")
  }
}
