// tells user of their progress in the current level

import Backbone from 'backbone'

import { subscribe } from '../../../store'

export default class Progress extends Backbone.View {

  get el() {
    return document.querySelector(`.current-run .description`)
  }

  initialize() {
    subscribe({
      'puzzles:fetched': puzzles => {
        this.updateProgress(0, puzzles.length)
      },
      'puzzles:status': ({ i , n }) => {
        this.updateProgress(i + 1, n)
      },
    })
  }

  updateProgress(i, n) {
    this.el.textContent = `${i} of ${n} solved`
  }
}
