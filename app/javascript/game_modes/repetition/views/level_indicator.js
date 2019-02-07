import Backbone from 'backbone'

import d from '../../../dispatcher'

// Level name, next level, etc.
//
export default class LevelIndicator extends Backbone.View {

  get el() {
    return document.querySelector(`.under-board`)
  }

  initialize() {
    this.levelNameEl = this.el.querySelector(`.level-name`)
    this.nextStageEl = this.el.querySelector(`.next-stage`)
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, `puzzles:start`, () => {
      this.levelNameEl.classList.add(`faded`)
    })
    this.listenTo(d, `level:unlocked`, () => {
      this.levelNameEl.classList.add(`invisible`)
      this.nextStageEl.classList.remove(`invisible`)
    })
  }
}
