const interact = require('interactjs')

export function makeDraggable(pieceEl) {
  let dragStarted = false
  let initialOffset = {
    x: 0,
    y: 0
  }
  interact(pieceEl)
    .draggable({ maxPerElement: Infinity })
    .styleCursor(false)
    .on(`mousedown`, () => dragStarted = false)
    .on(`dragstart`, e => {
      dragStarted = true
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
      const styles = [
        `transform: translate3d(${dx}px, ${dy}px, 0)`,
        `z-index: 5`
      ]
      e.currentTarget.style = styles.join(`;`)
    })
    .on(`dragend`, e => {
      e.currentTarget.style = `transform: translate3d(0, 0, 0); z-index: 1`
    })
    .on(`click`, e => {
      if (dragStarted) {
        e.stopImmediatePropagation()
      }
    })
}

export function makeDroppable(squareEl, onDrop) {
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
