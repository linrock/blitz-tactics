declare var require: any

const interact = require('interactjs')

import { ChessMove } from '../../../types'

const dragMoveStyle = (dx: number, dy: number): string => [
  `transform: translate3d(${dx}px, ${dy}px, 0)`,
  `z-index: 5`
].join(`;`)

const dragEndStyle = `transform: translate3d(0, 0, 0); z-index: 1`

export function makeDraggable(pieceEl: HTMLElement) {
  const initialOffset = {
    x: 0,
    y: 0
  }
  interact(pieceEl)
    .draggable({ maxPerElement: Infinity })
    .styleCursor(false)
    .on(`dragstart`, e => {
      const rect = interact.getElementRect(e.target)
      const startPos = {
        x: rect.left + rect.width / 2,
        y: rect.top + rect.height / 2
      }
      initialOffset.x = e.x0 - startPos.x
      initialOffset.y = e.y0 - startPos.y
    })
    .on(`dragmove`, e => {
      const dx = e.clientX - e.clientX0 + initialOffset.x
      const dy = e.clientY - e.clientY0 + initialOffset.y
      e.currentTarget.style = dragMoveStyle(dx, dy)
    })
    .on(`dragend`, e => e.currentTarget.style = dragEndStyle)
}

export function makeDroppable(squareEl: HTMLElement, onDrop: (move: ChessMove) => void) {
  interact(squareEl).dropzone({
    accept: `.piece`,
    ondrop: event => {
      const move = {
        from: event.draggable.target.parentNode.dataset.square,
        to: event.target.dataset.square
      }
      onDrop(move)
    }
  })
}
