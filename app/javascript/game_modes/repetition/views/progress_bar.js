import Backbone from 'backbone'

import d from '../../../dispatcher.ts'

// How close you are to the next round
//
export default class ProgressBar extends Backbone.View {

  get el() {
    return document.querySelector(`.progress-bar`)
  }

  initialize() {
    this.progressEl = this.el.querySelector(`.progress`)
    this.complete = false
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, `progress:update`, (percent) => {
      if (!this.complete) {
        this.updateProgress(percent)
      }
    })
  }

  updateProgress(percent) {
    this.progressEl.style = `width: ${percent}%`
    if (percent >= 100) {
      this.progressEl.classList.add(`complete`)
      this.complete = true
    }
  }
}
