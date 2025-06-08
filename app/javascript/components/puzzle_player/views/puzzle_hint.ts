import { dispatch, subscribe } from '@blitz/events'
import { UciMove } from '@blitz/types'
import { PuzzleState } from '../puzzle_source'

const comboDroppedAfterMs = 7_000
const hintDelay = 750

// Solution/hint that shows up after some time
//
export default class PuzzleHint {
  private moveEl: HTMLElement
  private buttonEl: HTMLElement
  private current: PuzzleState
  private timeout = 0

  get el(): HTMLElement {
    return document.querySelector(`.puzzle-hint`)
  }

  constructor() {
    this.moveEl = this.el.querySelector(`.move`)
    this.buttonEl = this.el.querySelector(`.hint-trigger`)
    
    // Add click handler to request hint from PuzzleSource
    this.buttonEl.addEventListener('click', () => {
      dispatch('puzzle:get_hint')
    })
    
    const events = ['mousedown', 'touchstart']
    events.forEach(event => {
      this.buttonEl.addEventListener(event, () => {
        this.buttonEl.classList.add(`invisible`)
      })
    })
    
    subscribe({
      'puzzle:loaded': (current: PuzzleState) => {
        this.current = current
        this.delayedShowHint()
      },
      'puzzle:hint': (hint: string) => {
        this.displayHint(hint)
      },
      'move:make': () => this.delayedShowHint(),
      'timer:stopped': () => this.clearHintTimer(),
    })
  }

  private displayHint(hint: string) {
    this.el.classList.remove(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    this.moveEl.textContent = hint
  }

  private clearHintTimer() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  private delayedShowHint() {
    this.clearHintTimer()
    if (!this.el) {
      return
    }
    // Show the button but hide any existing hint text
    this.el.classList.remove(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    this.moveEl.textContent = ``
    this.timeout = window.setTimeout(() => {
      dispatch(`move:too_slow`)
      setTimeout(() => dispatch('puzzle:get_hint'), hintDelay)
    }, comboDroppedAfterMs)
  }
}
