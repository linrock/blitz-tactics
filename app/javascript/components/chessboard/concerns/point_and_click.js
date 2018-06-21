// Point and click pieces to select and move them

import $ from 'jquery'
import d from '../../../dispatcher'

export default class PointAndClick {

  constructor(board) {
    this.board = board
    this.moveablePieces = ".piece.w"
    this.selectedSquare = false
    this.listenForEvents()
  }

  listenForEvents() {
    this.board.$el.on("click", ".square", event => {
      const square = event.currentTarget.dataset.square
      this.selectSquare(square)
    })
    this.board.listenTo(d, "move:try", () => this.clearSelected())
    this.board.listenTo(d, "move:make", () => this.clearSelected())
  }

  selectSquare(square) {
    if (this.board.$(`#${square} ${this.moveablePieces}`).length) {
      this.clearSelected()
      this.selectedSquare = square
      this.board.$(`#${this.selectedSquare}`).addClass("selected")
    } else if (this.selectedSquare && square !== this.selectedSquare) {
      const move = {
        from: this.selectedSquare,
        to: square
      }
      const $piece = this.board.$(`#${this.selectedSquare} .piece`)
      this.board.movePiece($piece, move)
      this.clearSelected()
    }
  }

  clearSelected() {
    this.selectedSquare = false
    this.board.$(".square.selected").removeClass("selected")
  }
}
