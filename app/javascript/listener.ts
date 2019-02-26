import _ from 'underscore'
import Backbone from 'backbone'

import d from './dispatcher'

interface EventMap {
  [event: string]: Backbone.EventHandler
}

export default class Listener {
  private readonly listener: Backbone.Events = _.clone(Backbone.Events)

  constructor(eventMap: EventMap) {
    Object.entries(eventMap).forEach(row => {
      const event: string = row[0]
      const handler: Backbone.EventHandler = row[1]
      this.listener.listenTo(d, event, handler)
    })
  }
}
