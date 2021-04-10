const boardSelector = '.chessground-board'
const resizerSelector = '.chessboard-resizer'

export default class ChessboardResizer {
  private chessboardEl: HTMLElement
  private resizerEl: HTMLElement

  constructor() {
    this.chessboardEl = document.querySelector(boardSelector)
    this.resizerEl = document.querySelector(resizerSelector)
    if (this.resizerEl && this.chessboardEl) {
      console.log('yay it worked')
      const zoomOutEl = this.resizerEl.querySelector('.zoom-out')
      zoomOutEl.addEventListener('click', () => this.shrinkBoard())
      const zoomInEl = this.resizerEl.querySelector('.zoom-in')
      zoomInEl.addEventListener('click', () => this.enlargeBoard())
    } else {
      if (!this.chessboardEl) {
        console.warn(`chessboard_resizer: failed to find ${boardSelector}`)
      }
      if (!this.resizerEl) {
        console.warn(`chessboard_resizer: failed to find ${resizerSelector}`)
      }
    }
  }

  private resizeBoard(width: number, height: number) {
    this.chessboardEl.style.width = `${width}px`
    this.chessboardEl.style.height = `${height}px`
  }

  private shrinkBoard() {
    const initialWidth = this.chessboardEl.clientWidth
    const initialHeight = this.chessboardEl.clientHeight
    this.resizeBoard(initialWidth - 16, initialHeight - 16)
  }

  private enlargeBoard() {
    const initialWidth = this.chessboardEl.clientWidth
    const initialHeight = this.chessboardEl.clientHeight
    this.resizeBoard(initialWidth + 16, initialHeight + 16)
  }
}