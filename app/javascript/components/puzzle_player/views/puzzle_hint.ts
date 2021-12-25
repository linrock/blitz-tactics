import _ from 'underscore'

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
      'move:make': () => this.delayedShowHint(),
      'timer:stopped': () => this.clearHintTimer(),
    })
  }

  private getRandomHint(): string {
    const hints: string[] = []
    _.each(_.keys(this.current.boardState), (move: UciMove) => {
      if (this.current.boardState[move] !== `retry`) {
        hints.push(move)
      }
    })
    return _.sample(hints)
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
    this.el.classList.add(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    this.moveEl.textContent = ``
    this.timeout = window.setTimeout(() => {
      dispatch(`move:too_slow`)
      setTimeout(() => this.showHint(), hintDelay)
    }, comboDroppedAfterMs)
  }

  private showHint() {
    this.el.classList.remove(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    this.moveEl.textContent = this.getRandomHint()
  }
}
