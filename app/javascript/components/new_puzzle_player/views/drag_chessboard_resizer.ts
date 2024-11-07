export default class DragChessboardResizer {
  private chessboardEl: HTMLElement
  private resizerEl: HTMLElement
  private boardAreaEl: HTMLElement

  constructor() {
    this.chessboardEl = document.querySelector('.chessground-board')
    this.resizerEl = document.querySelector('.new-chessboard-resizer')
    this.boardAreaEl = document.querySelector('.board-area')

    console.log('new chessboard resizer')
    let isDraggingResizer = false

    this.resizerEl.addEventListener('mousedown', () => {
      console.log('mousedown - new chessboard resizer')
      isDraggingResizer = true
    })

    document.addEventListener('mousemove', (event) => {
      if (isDraggingResizer) {
        // console.dir(event)
        const size = Math.round(Math.min(event.clientX, event.clientY));
        if (size % 4 == 0) {
          // console.log(`${event.clientX} ${event.clientY}`)
          this.resizeBoard(size)
        }
      }
    })

    document.addEventListener('mouseup', () => {
      console.log('mouseup - document')
      if (isDraggingResizer) {
        isDraggingResizer = false
      }
    })
  }

  private resizeBoard(size: number) {
    if (parseInt(this.boardAreaEl.style.width) !== size &&
        parseInt(this.boardAreaEl.style.height) !== size) {
      console.log(`board size: ${size}`)
      this.boardAreaEl.style.height = `${size}px`
      this.boardAreaEl.style.width = `${size}px`
    }
  }
}
