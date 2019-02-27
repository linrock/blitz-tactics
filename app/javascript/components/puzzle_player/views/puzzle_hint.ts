import _ from 'underscore'
import Backbone from 'backbone'

import { PuzzleState } from '../puzzle_source'
import { dispatch, subscribe } from '../../../store'
import { UciMove } from '../../../types'

const comboDroppedAfterMs = 7000
const hintDelay = 750

// Solution/hint that shows up after some time
//
export default class PuzzleHint extends Backbone.View<Backbone.Model> {
  private moveEl: HTMLElement
  private buttonEl: HTMLElement
  private current: PuzzleState
  private timeout = 0

  get el(): HTMLElement {
    return document.querySelector(`.puzzle-hint`)
  }

  events(): Backbone.EventsHash {
    return {
      "mousedown .hint-trigger" : `_showHint`,
      "touchstart .hint-trigger" : `_showHint`
    }
  }

  constructor() {
    super()
    this.moveEl = this.el.querySelector(`.move`)
    this.buttonEl = this.el.querySelector(`.hint-trigger`)
    subscribe({
      'puzzle:loaded': (current: PuzzleState) => {
        this.current = current
        this.delayedShowHint()
      },
      'move:make': () => this.delayedShowHint(),
      'timer:stopped': () => this.clearHintTimer()
    })
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
    this.timeout = setTimeout(() => {
      dispatch(`move:too_slow`)
      setTimeout(() => this.showHint(), hintDelay)
    }, comboDroppedAfterMs)
  }

  private showHint() {
    const hints = []
    _.each(_.keys(this.current.boardState), (move: UciMove) => {
      if (this.current.boardState[move] !== `retry`) {
        hints.push(move)
      }
    })
    this.el.classList.remove(`invisible`)
    this.buttonEl.classList.remove(`invisible`)
    this.moveEl.textContent = _.sample(hints)
  }

  private _showHint() {
    this.buttonEl.classList.add(`invisible`)
  }
}
