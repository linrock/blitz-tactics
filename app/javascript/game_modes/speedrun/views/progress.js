// tells user of their progress in the current level

import Backbone from 'backbone'

import d from '../../../dispatcher.ts'

export default class Progress extends Backbone.View {

  get el() {
    return document.querySelector(`.current-run .description`)
  }

  initialize() {
    this.listenTo(d, `puzzles:fetched`, puzzles => {
      this.updateProgress(0, puzzles.length)
    })
    this.listenTo(d, `puzzles:status`, ({ i , n }) => {
      this.updateProgress(i + 1, n)
    })
  }

  updateProgress(i, n) {
    this.el.textContent = `${i} of ${n} solved`
  }
}
