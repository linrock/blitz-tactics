// Type-safe event system using enums
// Simplified after migration from string-based events

import { GameEvent, GameEventMap, GameEventPayloads } from './game_events'

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

// Type-safe dispatch function - enum only
export function dispatch<T extends GameEvent>(
  eventName: T,
  ...data: GameEventPayloads[T] extends void ? [] : [GameEventPayloads[T]]
): void {
  dispatcher.trigger(eventName, ...data)
}

// Type-safe subscribe function - enum only
export function subscribe(eventMap: GameEventMap): void {
  Object.entries(eventMap).forEach(([eventName, handler]) => {
    if (handler) {
      dispatcher.on(eventName, handler)
    }
  })
}

// Type-safe subscribeOnce function - enum only
export function subscribeOnce<T extends GameEvent>(
  eventName: T,
  cb: GameEventPayloads[T] extends void ? () => void : (data: GameEventPayloads[T]) => void
): void {
  dispatcher.once(eventName, cb)
}

// Re-export GameEvent enum for convenience
export { GameEvent } from './game_events'
