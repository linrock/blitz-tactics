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
        // console.log(`${event.clientX} ${event.clientY}`)
        this.resizeBoard(size)
      }
    })

    document.addEventListener('mouseup', () => {
      console.log('mouseup - document')
      if (isDraggingResizer) {
        isDraggingResizer = false
      }
    })

    window.addEventListener("resize", (event) => {
      // console.dir(event)
      const size = Math.round(Math.min(
        window.outerWidth - 128,
        window.outerHeight - 256
      ))
      this.resizeBoard(size)
    })
  }

  private resizeBoard(size: number) {
    if (size % 8 !== 0) {
      return
    }
    if (parseInt(this.boardAreaEl.style.width) !== size &&
        parseInt(this.boardAreaEl.style.height) !== size) {
      requestAnimationFrame(() => {
        if (size > window.outerWidth - 128 || size > window.outerHeight - 192) {
          return;
        }
        console.log(`board size: ${size}`)
        this.boardAreaEl.style.height = `${size}px`
        this.boardAreaEl.style.width = `${size}px`
      })
    }
  }
}
