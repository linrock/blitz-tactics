import $ from 'jquery'

require('jquery-ui')
require('jquery-ui/ui/widgets/draggable')
require('jquery-ui/ui/widgets/droppable')

export function makeDraggable(pieceEl) {
  $(pieceEl).draggable({
    stack: `.piece`,
    distance: 10,
    revert: true,
    revertDuration: 0,
    containment: `body`,
    scroll: false
  })
}

export function makeDroppable(squareEl, onDrop) {
  $(squareEl).droppable({
    accept: `.piece`,
    tolerance: `pointer`,
    drop: (event, ui) => {
      const $piece = $(ui.draggable)
      const move = {
        from: $piece.parents(`.square`).data(`square`),
        to: $(event.target).data(`square`)
      }
      onDrop($piece, move)
    }
  })
}
