// instructions above the board for what to do in this position

import { getConfig } from '../../../utils'
import d from '../../../dispatcher'

export default class Instructions extends Backbone.View {

  get el() {
    return ".instructions"
  }

  initialize(options = {}) {
    this.initialFen = options.fen
    this.showInstructions()
    this.listenForEvents()
  }

  get toMove() {
    return this.initialFen.indexOf("w") > 0 ? "White" : "Black"
  }

  get goal() {
    return getConfig("goal")
  }

  get instructions() {
    if (this.goal === "win") {
      return this.toMove + " to play and win"
    } else if (this.goal === "draw") {
      return this.toMove + " to play and draw"
    }
    return this.toMove + " to move"
  }

  showInstructions() {
    this.$el.text(this.instructions)
    setTimeout(() => this.$el.removeClass("invisible"), 700)
  }

  gameOverMan(result) {
    let text
    if (this.goal === "win") {
      if ((this.toMove === "White" && result === "1-0") ||
          (this.toMove === "Black" && result === "0-1")) {
        text = "You win"
      } else {
        text = "You failed :("
      }
    } else if (this.goal === "draw" && result === "1/2-1/2") {
      text = "Success!"
    } else {
      text = "Game over"
    }
    this.$el.text(text)
    this.$el.removeClass("invisible")
  }

  listenForEvents() {
    this.listenTo(d, "position:reset", () => {
      this.showInstructions()
    })
    this.listenTo(d, "game:over", (result) => {
      this.gameOverMan(result)
    })
    this.listenTo(d, "move:try", () => {
      this.$el.addClass("invisible")
    })
  }
}
