import { dispatch, subscribe, GameEvent } from '@blitz/events'
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
      dispatch(GameEvent.PUZZLE_GET_HINT)
      // Hide button after click
      this.buttonEl.classList.add(`invisible`)
    })
    
    subscribe({
      [GameEvent.PUZZLE_LOADED]: (current: PuzzleState) => {
        this.current = current
        this.delayedShowHint()
      },
      [GameEvent.PUZZLE_HINT]: (hint: string) => {
        this.displayHint(hint)
        // Highlight the "from" square like Three game mode does
        const fromSquare = hint.slice(0, 2)
        dispatch(GameEvent.SHAPE_DRAW, fromSquare)
      },
      [GameEvent.MOVE_SUCCESS]: () => {
        // Hide the hint button after a successful move
        this.buttonEl.classList.add(`invisible`)
      },
      [GameEvent.MOVE_MAKE]: () => this.delayedShowHint(),
      [GameEvent.PUZZLE_SOLVED]: () => this.hideHint(),
      [GameEvent.TIMER_STOPPED]: () => this.clearHintTimer(),
    })
  }

  private displayHint(hint: string) {
    this.el.classList.remove(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    // Show only the "from" square to match what's highlighted on board
    this.moveEl.textContent = hint.slice(0, 2)
  }

  private hideHint() {
    this.clearHintTimer()
    this.el.classList.add(`invisible`)
    this.moveEl.textContent = ``
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
    this.moveEl.textContent = ``
    this.timeout = window.setTimeout(() => {
      dispatch(`move:too_slow`)
      // Hide combo counter when hint button appears
      dispatch(GameEvent.COMBO_DROP)
      setTimeout(() => {
        // Only show the hint button, don't automatically get the hint
        this.el.classList.remove(`invisible`)
        this.buttonEl.classList.remove(`invisible`)
      }, hintDelay)
    }, comboDroppedAfterMs)
  }
}
