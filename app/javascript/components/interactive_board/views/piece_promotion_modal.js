import Backbone from 'backbone'
import Mousetrap from 'mousetrap'
import Chess from 'chess.js'

import d from '../../../dispatcher.ts'

// When you make a pawn move that requires pawn promotion,
// this is what shows up
//
export default class PiecePromotionModal extends Backbone.View {

  get el() {
    return document.querySelector(`.piece-promotion-modal-container`)
  }

  get events() {
    return {
      'click .piece' : `_selectPiece`
    }
  }

  initialize() {
    this.cjs = new Chess()
    this.moveIntent = false
    this.listenToEvents()
  }

  show() {
    this.el.style = `display: block`
    Mousetrap.bind(`esc`, () => this.hide())
  }

  hide() {
    this.el.style = `display: none`
    Mousetrap.unbind(`esc`)
  }

  listenToEvents() {
    this.listenTo(d, `move:promotion`, (data) => {
      this.fen = data.fen
      this.moveIntent = data.move
      this.show()
    })
  }

  _selectPiece(e) {
    const chosenPiece = e.currentTarget.dataset.piece
    const move = Object.assign({}, this.moveIntent, { promotion: chosenPiece })
    this.cjs.load(this.fen)
    const m = this.cjs.move(move)
    if (m) {
      d.trigger(`move:try`, m)
    }
    this.hide()
  }
}
