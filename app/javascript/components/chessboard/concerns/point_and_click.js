// Point and click pieces to select and move them

import d from '../../../dispatcher.ts'

export default class PointAndClick {

  constructor(board) {
    this.board = board
    this.moveablePieceColor = `w`
    this.selectedSquare = false
    this.listenForEvents()
  }

  listenForEvents() {
    [`mousedown`, `touchstart`].forEach(clickEvent => {
      this.board.delegate(clickEvent, `.square`, event => {
        this.clickedSquare(event.currentTarget.dataset.square)
      })
    })
    this.board.listenTo(d, `move:try`, () => this.clearSelected())
    this.board.listenTo(d, `move:make`, () => this.clearSelected())
  }

  clickedSquare(squareId) {
    const piece = this.board.cjs.get(squareId)
    if (this.selectedSquare && squareId !== this.selectedSquare) {
      if (this.isMoveable(piece)) {
        this.selectSquare(squareId)
      } else {
        const move = {
          from: this.selectedSquare,
          to: squareId
        }
        this.board.tryMove(move)
      }
    } else if (this.isMoveable(piece)) {
      this.selectSquare(squareId)
    }
  }

  selectSquare(squareId) {
    this.clearSelected()
    this.selectedSquare = squareId
    this.board.highlightSquare(squareId, `data-selected`)
    this.board.renderVirtualDom()
  }

  clearSelected() {
    if (!this.selectedSquare) {
      return
    }
    this.board.unhighlightSquare(this.selectedSquare)
    this.selectedSquare = false
    this.board.renderVirtualDom()
  }

  isMoveable(piece) {
    return piece && piece.color === this.moveablePieceColor
  }
}
