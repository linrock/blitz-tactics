const RESIZE_GRAIN = 8;

export default class DragChessboardResizer {
  private resizerEl: HTMLElement
  private boardAreaEl: HTMLElement

  constructor() {
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
        const size = RESIZE_GRAIN * Math.round(Math.min(event.clientX, event.clientY) / RESIZE_GRAIN);
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
      const size = RESIZE_GRAIN * Math.round(Math.min(
        window.innerWidth - 128,
        window.innerHeight - 256
      ) / RESIZE_GRAIN)
      this.resizeBoard(size)
    })
  }

  private resizeBoard(size: number) {
    if (size % RESIZE_GRAIN !== 0) {
      return
    }
    if (size > window.innerWidth - 128 || size > window.innerHeight - 192) {
      return;
    }
    if (parseInt(this.boardAreaEl.style.width) === size &&
        parseInt(this.boardAreaEl.style.height) === size) {
      return;
    }
    requestAnimationFrame(() => {
      console.log(`board size: ${size}`)
      this.boardAreaEl.style.height = `${size}px`
      this.boardAreaEl.style.width = `${size}px`
    })
  }
}
