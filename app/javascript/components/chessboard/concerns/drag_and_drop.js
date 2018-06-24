import $ from 'jquery'

require('jquery-ui');
require('jquery-ui/ui/widgets/draggable');
require('jquery-ui/ui/widgets/droppable');

// Drag and drop pieces to move them
//
export default class DragAndDrop {

  constructor(board) {
    this.board = board
    this.initialized = false
  }

  init() {
    if (this.initialized) {
      return
    }
    this.initDroppable()
    this.initialized = true
  }

  initDraggable() {
    this.board.$(`.piece:not(.ui-draggable)`).draggable({
      stack: `.piece`,
      distance: 10,
      revert: true,
      revertDuration: 0,
      containment: `body`,
      scroll: false
    })
  }

  initDroppable() {
    this.board.$(`.square`).droppable({
      accept: `.piece`,
      tolerance: `pointer`,
      drop: (event, ui) => {
        const $piece = $(ui.draggable)
        const move = {
          from: $piece.parents(`.square`).data(`square`),
          to: $(event.target).data(`square`)
        }
        this.board.movePiece($piece, move)
      }
    })
  }
}
