import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class NoMoreLeft extends Backbone.View {
  get el() {
    return ".no-more-left"
  }

  initialize() {
    this.listenForDifficulty()
    this.listenTo(d, "puzzles:complete", () => {
      this.$el.removeClass("invisible")
      this.stopListening(d, "difficulty:set")
      this.listenToOnce(d, "difficulty:set", () => {
        this.$el.addClass("invisible")
        setTimeout(() => this.listenForDifficulty(), 1000)
      })
    })
  }

  listenForDifficulty() {
    this.listenTo(d, "difficulty:set", difficulty => {
      this.$el.find(".difficulty").text(difficulty)
    })
  }
}
