// Point and click pieces to select and move them

import { ChessMove } from '../../../types.ts'
import Listener from '../../../listener.ts'
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
      this.board.el.addEventListener(clickEvent, event => {
        let targetEl = <HTMLElement>event.target
        while (targetEl !== this.board.el) {
          if (targetEl.classList.contains(`square`)) {
            this.clickedSquare(targetEl.dataset.square)
            event.stopPropagation()
          }
          targetEl = targetEl.parentElement
        }
      })
    })
    new Listener({
      'move:try': () => this.clearSelected(),
      'move:make': () => this.clearSelected()
    })
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
