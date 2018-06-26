// instructions that fade out after you start

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Sidebar extends Backbone.View {

  get el() {
    return document.querySelector(`.speedrun-sidebar`)
  }

  get events() {
    return {
      'click [data-name]': `_chooseLevel`,
    }
  }

  initialize() {
    const instructionsEl = this.el.querySelector(`.speedrun-instructions`)
    const nPuzzlesEl = this.el.querySelector(`.n-puzzles`)
    this.listenTo(d, `level:selected`, name => this.highlight(name))
    this.listenTo(d, `puzzles:fetched`, puzzles => {
      nPuzzlesEl.textContent = `${puzzles.length} puzzles`
      nPuzzlesEl.classList.remove(`invisible`)
    })
    this.listenTo(d, `move:try`, () => {
      instructionsEl.remove()
      this.el.querySelector(`.make-a-move`).remove()
      this.el.querySelector(`.timers`).style = ``
      this.stopListening()
    })
  }

  highlight(name) {
    const selectedEl = this.el.querySelector(`.selected`)
    if (selectedEl) {
      selectedEl.classList.remove(`selected`)
    }
    this.el.querySelector(`[data-name="${name}"]`).classList.add(`selected`)
  }

  _chooseLevel(e) {
    const el = e.currentTarget
    if (el.classList.toString().includes(`selected`)) {
      return
    }
    d.trigger(`level:selected`, el.dataset.name)
  }
}
