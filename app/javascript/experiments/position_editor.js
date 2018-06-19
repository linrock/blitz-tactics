import $ from 'jquery'
import Backbone from 'backbone'

import d from '../dispatcher'

export default class PositionEditor extends Backbone.View {

  get el() {
    return ".position-editor"
  }

  get events() {
    return {
      "keyup .fen-input" : "updateBoard"
    }
  }

  initialize() {
    console.log("initializing")
    this.$fen = this.$(".fen-input")
    this.updateBoard()
  }

  fen() {
    let fen = $.trim(this.$fen.val())
    fen = fen.split(" ").length === 4 ? `${fen} 0 1` : fen
    let check = new Chess().validate_fen(fen)
    if (!check.valid) {
      d.trigger("fen:error", check.error)
      return
    }
    return fen
  }

  updateBoard() {
    let fen = this.fen()
    if (fen) {
      d.trigger("fen:set", fen)
    }
  }
}

// 4k3/8/8/8/8/8/8/4KBN1 w - -
