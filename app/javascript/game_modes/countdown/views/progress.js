// tells user of their progress in the current level

import Backbone from 'backbone'

import { dispatch, subscribe } from '../../../store'

export default class Progress extends Backbone.View {

  get el() {
    return document.querySelector(`.current-countdown .description`)
  }

  initialize() {
    this.nSolved = 0
    subscribe({
      'puzzles:status': ({ i }) => {
        this.nSolved = i + 1
        this.updateProgress()
      },
      'timer:stopped': () => {
        dispatch(`timer:complete`, this.nSolved)
      },
    })
  }

  updateProgress() {
    this.el.textContent = `${this.nSolved} puzzles solved`
  }
}
