import _ from 'underscore'
import Backbone from 'backbone'

import d from './dispatcher'

interface EventMap {
  [event: string]: Backbone.EventHandler
}

const listener = _.clone(Backbone.Events)

const dispatch = (eventName: string, ...data) => {
  d.trigger(eventName, ...data)
}

const subscribe = (eventMap: EventMap) => {
  Object.entries(eventMap).forEach(row => {
    const eventName: string = row[0]
    const handler: Backbone.EventHandler = row[1]
    listener.listenTo(d, eventName, handler)
  })
}

const subscribeOnce = (eventName: string, callback: Function) => {
  listener.listenToOnce(d, eventName, callback)
}

export {
  dispatch,
  subscribe,
  subscribeOnce,
}
