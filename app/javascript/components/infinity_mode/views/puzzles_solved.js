import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class PuzzlesSolved extends Backbone.View {

  get el() {
    return ".n-puzzles"
  }

  initialize() {
    this.listenTo(d, "yeah", () => {})
  }
}
