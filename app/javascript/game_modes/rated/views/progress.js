// tells user of their progress in the current level

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Progress extends Backbone.View {

  get el() {
    return document.querySelector(`.current-status .n-solved`)
  }

  initialize() {
    this.nSolved = 0
    this.listenTo(d, `puzzles:status`, ({ i }) => {
      this.nSolved = i + 1
      this.updateProgress()
    })
    this.listenTo(d, `timer:stopped`, () => {
      d.trigger(`timer:complete`, this.nSolved)
    })
  }

  updateProgress() {
    this.el.textContent = `${this.nSolved} puzzles solved`
  }
}
