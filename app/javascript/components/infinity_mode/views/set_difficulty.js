import $ from 'jquery'
import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class SetDifficulty extends Backbone.View {

  get el() {
    return ".difficulties"
  }

  get events() {
    return {
      "click div": "_selectDifficulty"
    }
  }

  initialize() {
    this.$el.find("div")[0].classList.add("selected")
  }

  _selectDifficulty(e) {
    const el = e.currentTarget
    if (el.classList.toString().includes("selected")) {
      return
    }
    this.$el.find(".selected").removeClass("selected")
    el.classList.add("selected")
    d.trigger("difficulty:selected", el.dataset.difficulty)
  }
}
