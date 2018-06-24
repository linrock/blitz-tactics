// instructions that fade out after you start

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Sidebar extends Backbone.View {

  get el() {
    return `.speedrun-sidebar`
  }

  get events() {
    return {
      'click [data-name]': `_chooseLevel`,
    }
  }

  initialize() {
    this.$instructions = this.$(`.speedrun-instructions`)
    this.$nPuzzles = this.$(`.n-puzzles`)
    this.listenTo(d, `level:selected`, name => this.highlight(name))
    this.listenTo(d, `puzzles:fetched`, puzzles => {
      this.$nPuzzles.text(`${puzzles.length} puzzles`).removeClass(`invisible`)
    })
    this.listenTo(d, `move:try`, () => {
      this.$instructions.remove()
      this.$(`.make-a-move`).remove()
      this.$(`.timers`).show()
      this.stopListening()
    })
  }

  highlight(name) {
    this.$(`.selected`).removeClass(`selected`)
    this.$(`[data-name="${name}"]`).addClass(`selected`)
  }

  _chooseLevel(e) {
    const el = e.currentTarget
    if (el.classList.toString().includes(`selected`)) {
      return
    }
    d.trigger(`level:selected`, el.dataset.name)
  }
}
