// tells user of their progress in the current level

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Progress extends Backbone.View {

  get el() {
    return `.current-run .description`
  }

  initialize() {
    this.listenToOnce(d, `puzzles:fetched`, puzzles => {
      this.n = puzzles.length
    })
    this.listenToOnce(d, `move:try`, () => {
      this.updateProgress(0, this.n)
    })
    this.listenTo(d, `puzzles:status`, status => {
      const { i, n } = status
      this.updateProgress(i + 1, n)
    })
  }

  updateProgress(i, n) {
    this.$el.text(`${i} of ${n} solved`)
  }
}
