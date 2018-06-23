import _ from 'underscore'
import Backbone from 'backbone'

import d from 'dispatcher'

export default class Listener {
  constructor(eventMap) {
    this.listener = _.clone(Backbone.Events)
    this.listenToEvents(eventMap)
  }

  listenToEvents(eventMap) {
    Object.entries(eventMap).forEach(([event, handler]) => {
      this.listener.listenTo(d, event, handler)
    })
  }
}
