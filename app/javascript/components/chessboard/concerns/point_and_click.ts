// Point and click pieces to select and move them

import { ChessMove } from '../../../types.ts'
import d from '../../../dispatcher.ts'
import Chessboard from '../chessboard.ts'

export default class PointAndClick {
  private board: Chessboard
  private moveablePieceColor = `w`
  private selectedSquare: string|boolean = false

  constructor(board) {
    this.board = board
    this.listenForEvents()
  }

  private listenForEvents() {
    [`mousedown`, `touchstart`].forEach(clickEvent => {
      this.board.delegate(clickEvent, `.square`, event => {
        this.clickedSquare(event.currentTarget.dataset.square)
      })
    })
    this.board.listenTo(d, `move:try`, () => this.clearSelected())
    this.board.listenTo(d, `move:make`, () => this.clearSelected())
  }

  private clickedSquare(squareId) {
    const piece = this.board.cjs.get(squareId)
    if (this.selectedSquare && squareId !== this.selectedSquare) {
      if (this.isMoveable(piece)) {
        this.selectSquare(squareId)
      } else {
        const move: ChessMove = {
          from: <string>this.selectedSquare,
          to: squareId
        }
        this.board.tryMove(move)
      }
    } else if (this.isMoveable(piece)) {
      this.selectSquare(squareId)
    }
  }

  private selectSquare(squareId) {
    this.clearSelected()
    this.selectedSquare = squareId
    this.board.highlightSquare(squareId, `data-selected`)
    this.board.renderVirtualDom()
  }

  private clearSelected() {
    if (!this.selectedSquare) {
      return
    }
    this.board.unhighlightSquare(this.selectedSquare)
    this.selectedSquare = false
    this.board.renderVirtualDom()
  }

  private isMoveable(piece): boolean {
    return piece && piece.color === this.moveablePieceColor
  }
}
