// Point and click pieces to select and move them

import d from '../../../dispatcher'

export default class PointAndClick {

  constructor(board) {
    this.board = board
    this.moveablePieces = `.piece.w`
    this.selectedSquare = false
    this.listenForEvents()
  }

  listenForEvents() {
    this.board.$el.on(`click`, `.square`, event => {
      this.selectSquare(event.currentTarget.dataset.square)
    })
    this.board.listenTo(d, `move:try`, () => this.clearSelected())
    this.board.listenTo(d, `move:make`, () => this.clearSelected())
  }

  selectSquare(square) {
    if (this.board.$(`#${square} ${this.moveablePieces}`).length) {
      this.clearSelected()
      this.selectedSquare = square
      this.board.$(`#${this.selectedSquare}`).addClass(`selected`)
    } else if (this.selectedSquare && square !== this.selectedSquare) {
      const move = {
        from: this.selectedSquare,
        to: square
      }
      const pieceEl = this.board.$el[0].querySelector(`#${this.selectedSquare} .piece`)
      this.board.movePiece(pieceEl, move)
      this.clearSelected()
    }
  }

  clearSelected() {
    this.selectedSquare = false
    this.board.$(`.square.selected`).removeClass(`selected`)
  }
}
