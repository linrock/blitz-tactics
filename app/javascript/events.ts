// Custom event system to replace Backbone.Events

interface EventMap {
  [event: string]: (...args: any[]) => void
}

class EventEmitter {
  private listeners: { [event: string]: ((...args: any[]) => void)[] } = {}

  trigger(eventName: string, ...data: any[]) {
    if (this.listeners[eventName]) {
      this.listeners[eventName].forEach(handler => handler(...data))
    }
  }

  on(eventName: string, handler: (...args: any[]) => void) {
    if (!this.listeners[eventName]) {
      this.listeners[eventName] = []
    }
    this.listeners[eventName].push(handler)
  }

  once(eventName: string, handler: (...args: any[]) => void) {
    const onceHandler = (...args: any[]) => {
      handler(...args)
      this.off(eventName, onceHandler)
    }
    this.on(eventName, onceHandler)
  }

  off(eventName: string, handler: (...args: any[]) => void) {
    if (this.listeners[eventName]) {
      const index = this.listeners[eventName].indexOf(handler)
      if (index > -1) {
        this.listeners[eventName].splice(index, 1)
      }
    }
  }
}

const dispatcher = new EventEmitter()

const dispatch = (eventName: string, ...data: any[]) => {
  dispatcher.trigger(eventName, ...data)
}

const subscribe = (eventMap: EventMap) => {
  Object.entries(eventMap).forEach(([eventName, handler]) => {
    dispatcher.on(eventName, handler)
  })
}

const subscribeOnce = (eventName: string, cb: (...args: any[]) => void) => {
  dispatcher.once(eventName, cb)
}

export {
  dispatch,
  subscribe,
  subscribeOnce,
}
