// Point and click pieces to select and move them

import { ShortMove, Square } from 'chess.js'

import { subscribe } from '@blitz/store'
import Chessboard from '../chessboard'

export default class PointAndClick {
  private selectedSquare: string|boolean = false

  constructor(private board: Chessboard) {
    this.board = board
    this.listenForEvents()
  }

  private listenForEvents(): void {
    const boardEl = this.board.el
    const clickEvents = [`mousedown`, `touchstart`]
    clickEvents.forEach(clickEvent => {
      boardEl.addEventListener(clickEvent, event => {
        let targetEl = <HTMLElement>event.target
        while (targetEl && targetEl !== boardEl) {
          if (targetEl.classList.contains(`square`)) {
            this.clickedSquare(targetEl.dataset.square)
            event.stopPropagation()
          }
          targetEl = targetEl.parentElement
        }
      })
    })
    subscribe({
      'move:try': () => this.clearSelected(),
      'move:make': () => this.clearSelected()
    })
  }

  private clickedSquare(squareId): void {
    const piece = this.board.cjs.get(squareId)
    if (this.selectedSquare && squareId !== this.selectedSquare) {
      if (this.isMoveable(piece)) {
        this.selectSquare(squareId)
      } else {
        const move: ShortMove = {
          from: (this.selectedSquare as Square),
          to: squareId
        }
        this.board.tryMove(move)
      }
    } else if (this.isMoveable(piece)) {
      this.selectSquare(squareId)
    }
  }

  private selectSquare(squareId): void {
    this.clearSelected()
    this.selectedSquare = squareId
    this.board.highlightSquare(squareId, `data-selected`)
    this.board.renderVirtualDom()
  }

  private clearSelected(): void {
    if (!this.selectedSquare) {
      return
    }
    this.board.unhighlightSquare(this.selectedSquare as Square)
    this.selectedSquare = false
    this.board.renderVirtualDom()
  }

  private moveablePieceColor(): string {
    return this.board.isFlipped ? `b` : `w`
  }

  private isMoveable(piece): boolean {
    return piece && piece.color === this.moveablePieceColor()
  }
}
