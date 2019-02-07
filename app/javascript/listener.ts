import Backbone from 'backbone'

import d from './dispatcher'

interface EventMap {
  [event: string]: Function
}

export default class Listener {
  private readonly listener: any

  constructor(eventMap: EventMap) {
    this.listener = Object.assign({}, Backbone.Events)
    this.listenToEvents(eventMap)
  }

  private listenToEvents(eventMap) {
    Object.entries(eventMap).forEach(row => {
      const event: string = row[0]
      const handler = <Function>row[1]
      this.listener.listenTo(d, event, handler)
    })
  }
}
