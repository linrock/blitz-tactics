import Backbone from 'backbone'

import { dispatch, subscribe } from '../../../store'

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
    subscribe({
      'difficulty:set': difficulty => this.highlight(difficulty)
    })
  }

  highlight(difficulty) {
    const selectedEl = this.el.querySelector(`.selected`)
    if (selectedEl) {
      selectedEl.classList.remove(`selected`)
    }
    this.el.querySelector(`[data-difficulty="${difficulty}"]`).classList.add(`selected`)
  }

  _selectDifficulty(e, childElement) {
    const el = childElement
    if (el.classList.toString().includes(`selected`)) {
      return
    }
    dispatch(`difficulty:selected`, el.dataset.difficulty)
  }
}
