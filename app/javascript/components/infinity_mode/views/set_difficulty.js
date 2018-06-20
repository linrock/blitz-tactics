import $ from 'jquery'
import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class SetDifficulty extends Backbone.View {

  get el() {
    return ".difficulties"
  }

  get events() {
    return {
      "click [data-difficulty]": "_selectDifficulty"
    }
  }

  initialize() {
    this.listenTo(d, "difficulty:set", difficulty => this.highlight(difficulty))
  }

  highlight(difficulty) {
    this.$el.find(".selected").removeClass("selected")
    this.$el.find(`[data-difficulty="${difficulty}"]`).addClass("selected")
  }

  _selectDifficulty(e) {
    const el = e.currentTarget
    if (el.classList.toString().includes("selected")) {
      return
    }
    d.trigger("difficulty:selected", el.dataset.difficulty)
    d.trigger("difficulty:set", el.dataset.difficulty)
  }
}
