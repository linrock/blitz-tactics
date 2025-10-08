const RESIZE_GRAIN = 8;

export default class DragChessboardResizer {
  private resizerEl: HTMLElement
  private boardAreaEl: HTMLElement

  constructor() {
    this.resizerEl = document.querySelector('.new-chessboard-resizer')
    this.boardAreaEl = document.querySelector('.board-area')

    console.log('new chessboard resizer')
    let initialSize, clickedX, clickedY
    let isDraggingResizer = false

    this.resizerEl.addEventListener('mousedown', (event) => {
      console.log('mousedown - new chessboard resizer')
      initialSize = parseInt(this.boardAreaEl.style.width)
      clickedX = event.clientX
      clickedY = event.clientY
      isDraggingResizer = true
    })

    document.addEventListener('mousemove', (event) => {
      if (isDraggingResizer) {
        const diffX = event.clientX - clickedX
        const diffY = event.clientY - clickedY
        console.log(`diff xy: ${diffX}, ${diffY}`)
        
        // console.dir(event)
        const size = RESIZE_GRAIN * Math.round(Math.min(
          initialSize + diffX,
          initialSize + diffY
        ) / RESIZE_GRAIN);
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
      const maxSize = RESIZE_GRAIN * Math.round(Math.min(
        window.innerWidth - 128,
        window.innerHeight - 256
      ) / RESIZE_GRAIN)
      
      const currentSize = parseInt(this.boardAreaEl.style.width) || 512
      
      // Only resize if current size exceeds the new maximum
      if (currentSize > maxSize) {
        this.resizeBoard(maxSize)
      }
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
      this.boardAreaEl.style.height = `${size}px`
      this.boardAreaEl.style.width = `${size}px`
      
      // Also set the CSS variable to override any CSS rules
      document.documentElement.style.setProperty('--board-size', `${size}px`)
    })
  }
}
