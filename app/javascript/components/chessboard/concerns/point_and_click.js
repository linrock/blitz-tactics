// Point and click pieces to select and move them

import d from '../../../dispatcher'

export default class PointAndClick {

  constructor(board) {
    this.board = board
    this.moveablePieceColor = `w`
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

  selectSquare(squareId) {
    const piece = this.board.cjs.get(squareId)
    if (piece && piece.color === this.moveablePieceColor) {
      this.selectedSquare = squareId
      this.board.highlightSquare(squareId, `data-selected`)
      this.board.renderVirtualDom()
    } else if (this.selectedSquare && squareId !== this.selectedSquare) {
      const move = {
        from: this.selectedSquare,
        to: squareId
      }
      this.board.tryMove(move)
      this.clearSelected()
    }
  }

  clearSelected() {
    if (!this.selectedSquare) {
      return
    }
    this.board.unhighlightSquare(this.selectedSquare)
    this.selectedSquare = false
    this.board.renderVirtualDom()
  }
}
