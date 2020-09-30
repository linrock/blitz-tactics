import Backbone from 'backbone'

import { dispatch, subscribe } from '@blitz/store'

export default class SetDifficulty extends Backbone.View<Backbone.Model> {

  get el(): HTMLElement {
    return document.querySelector(`.difficulties`)
  }

  events(): Backbone.EventsHash {
    return {
      'click [data-difficulty]': `_selectDifficulty`
    }
  }

  public initialize() {
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
