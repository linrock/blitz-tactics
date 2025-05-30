type EventHandler = (...args: any[]) => void

interface EventMap {
  [event: string]: EventHandler
}

class SimpleEventEmitter {
  private listeners: Record<string, EventHandler[]> = {}

  on(event: string, handler: EventHandler) {
    if (!this.listeners[event]) {
      this.listeners[event] = []
    }
    this.listeners[event].push(handler)
  }

  off(event: string, handler?: EventHandler) {
    if (!this.listeners[event]) return
    
    if (handler) {
      this.listeners[event] = this.listeners[event].filter(h => h !== handler)
    } else {
      delete this.listeners[event]
    }
  }

  trigger(event: string, ...args: any[]) {
    if (!this.listeners[event]) return
    
    this.listeners[event].forEach(handler => {
      try {
        handler(...args)
      } catch (error) {
        console.error(`Error in event handler for "${event}":`, error)
      }
    })
  }

  once(event: string, handler: EventHandler) {
    const onceHandler = (...args: any[]) => {
      handler(...args)
      this.off(event, onceHandler)
    }
    this.on(event, onceHandler)
  }
}

const dispatcher = new SimpleEventEmitter()
const listener = new SimpleEventEmitter()

const dispatch = (eventName: string, ...data: any[]) => {
  dispatcher.trigger(eventName, ...data)
}

const subscribe = (eventMap: EventMap) => {
  Object.entries(eventMap).forEach(([eventName, handler]) => {
    listener.on(eventName, handler)
    dispatcher.on(eventName, handler)
  })
}

const subscribeOnce = (eventName: string, cb: EventHandler) => {
  dispatcher.once(eventName, cb)
}

export {
  dispatch,
  subscribe,
  subscribeOnce,
}
