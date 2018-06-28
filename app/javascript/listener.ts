import _ from 'underscore'
import Backbone from 'backbone'

import d from './dispatcher.ts'

interface EventMap {
  [event: string]: Function
}

export default class Listener {
  listener: Backbone.Events

  constructor(eventMap: EventMap) {
    this.listener = _.clone(Backbone.Events)
    this.listenToEvents(eventMap)
  }

  private listenToEvents(eventMap) {
    Object.entries(eventMap).forEach(([event, handler]) => {
      this.listener.listenTo(d, event, handler)
    })
  }
}
