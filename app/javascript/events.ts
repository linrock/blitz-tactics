// Custom event system to replace Backbone.Events
// Enhanced with type-safe enum support

import { GameEvent, GameEventMap, GameEventPayloads } from './game_events'

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

// Type-safe dispatch function with enum support
function dispatch<T extends GameEvent>(
  eventName: T,
  ...data: GameEventPayloads[T] extends void ? [] : [GameEventPayloads[T]]
): void;
function dispatch(eventName: string, ...data: any[]): void;
function dispatch(eventName: string | GameEvent, ...data: any[]) {
  dispatcher.trigger(eventName, ...data)
}

// Type-safe subscribe function with enum support
function subscribe(eventMap: GameEventMap): void;
function subscribe(eventMap: EventMap): void;
function subscribe(eventMap: EventMap | GameEventMap) {
  Object.entries(eventMap).forEach(([eventName, handler]) => {
    if (handler) {
      dispatcher.on(eventName, handler)
    }
  })
}

// Type-safe subscribeOnce function
function subscribeOnce<T extends GameEvent>(
  eventName: T,
  cb: GameEventPayloads[T] extends void ? () => void : (data: GameEventPayloads[T]) => void
): void;
function subscribeOnce(eventName: string, cb: (...args: any[]) => void): void;
function subscribeOnce(eventName: string | GameEvent, cb: (...args: any[]) => void) {
  dispatcher.once(eventName, cb)
}

export {
  dispatch,
  subscribe,
  subscribeOnce,
}

// Re-export GameEvent enum for convenience
export { GameEvent } from './game_events'
