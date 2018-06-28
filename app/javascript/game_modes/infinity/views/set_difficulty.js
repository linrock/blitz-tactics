import Backbone from 'backbone'

import d from '../../../dispatcher.ts'

export default class SetDifficulty extends Backbone.View {

  get el() {
    return document.querySelector(`.difficulties`)
  }

  get events() {
    return {
      'click [data-difficulty]': `_selectDifficulty`
    }
  }

  initialize() {
    this.listenTo(d, `difficulty:set`, difficulty => this.highlight(difficulty))
  }

  highlight(difficulty) {
    const selectedEl = this.el.querySelector(`.selected`)
    if (selectedEl) {
      selectedEl.classList.remove(`selected`)
    }
    this.el.querySelector(`[data-difficulty="${difficulty}"]`).classList.add(`selected`)
  }

  _selectDifficulty(e) {
    const el = e.currentTarget
    if (el.classList.toString().includes(`selected`)) {
      return
    }
    d.trigger(`difficulty:selected`, el.dataset.difficulty)
  }
}
