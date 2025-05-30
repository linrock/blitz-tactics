const boardSelector = '.chessground-board'
const resizerSelector = '.chessboard-resizer'

export default class ChessboardResizer {
  private chessboardEl: HTMLElement
  private resizerEl: HTMLElement
  private dragHandle: HTMLElement
  private isDragging: boolean = false
  private startX: number = 0
  private startY: number = 0
  private startWidth: number = 0
  private startHeight: number = 0

  // Bound event handlers for easy cleanup
  private boundMouseMove: (e: MouseEvent) => void
  private boundMouseUp: (e: MouseEvent) => void

  constructor() {
    this.chessboardEl = document.querySelector(boardSelector)
    this.resizerEl = document.querySelector(resizerSelector)
    
    // Bind event handlers
    this.boundMouseMove = this.handleMouseMove.bind(this)
    this.boundMouseUp = this.handleMouseUp.bind(this)
    
    if (this.chessboardEl) {
      this.createDragHandle()
      this.setupDragEventListeners()
    }
    
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

  private createDragHandle() {
    // Create the drag handle element
    this.dragHandle = document.createElement('div')
    this.dragHandle.className = 'chessboard-drag-handle'
    this.dragHandle.innerHTML = '⋰' // Resize icon
    this.dragHandle.title = 'Drag to resize board'
    
    // Position it in the bottom-right corner
    this.chessboardEl.style.position = 'relative'
    this.chessboardEl.appendChild(this.dragHandle)
  }

  private setupDragEventListeners() {
    this.dragHandle.addEventListener('mousedown', this.handleMouseDown.bind(this))
    document.addEventListener('mousemove', this.boundMouseMove)
    document.addEventListener('mouseup', this.boundMouseUp)
    
    // Prevent text selection while dragging
    this.dragHandle.addEventListener('selectstart', e => e.preventDefault())
    this.dragHandle.addEventListener('dragstart', e => e.preventDefault())
  }

  private handleMouseDown(e: MouseEvent) {
    e.preventDefault()
    e.stopPropagation()
    
    this.isDragging = true
    this.startX = e.clientX
    this.startY = e.clientY
    this.startWidth = this.chessboardEl.clientWidth
    this.startHeight = this.chessboardEl.clientHeight
    
    // Add dragging class for visual feedback
    this.dragHandle.classList.add('dragging')
    document.body.style.cursor = 'nw-resize'
    document.body.style.userSelect = 'none'
  }

  private handleMouseMove(e: MouseEvent) {
    if (!this.isDragging) return
    
    e.preventDefault()
    
    const deltaX = e.clientX - this.startX
    const deltaY = e.clientY - this.startY
    
    // Use the larger of the two deltas to maintain square aspect ratio
    const delta = Math.max(deltaX, deltaY)
    const newSize = Math.max(200, this.startWidth + delta) // Minimum size of 200px
    
    this.resizeBoard(newSize, newSize)
  }

  private handleMouseUp(e: MouseEvent) {
    if (!this.isDragging) return
    
    this.isDragging = false
    this.dragHandle.classList.remove('dragging')
    document.body.style.cursor = ''
    document.body.style.userSelect = ''
  }

  private resizeBoard(width: number, height: number) {
    this.chessboardEl.style.width = `${width}px`
    this.chessboardEl.style.height = `${height}px`
    const boardAreaEl: HTMLElement = document.querySelector('.board-area')
    if (boardAreaEl) {
      boardAreaEl.style.width = `${width}px`
    }
    const aboveBoardEl: HTMLElement = document.querySelector('.above-board')
    if (aboveBoardEl) {
      aboveBoardEl.style.width = `${width}px`
    }
  }

  private shrinkBoard() {
    const initialWidth = this.chessboardEl.clientWidth
    const initialHeight = this.chessboardEl.clientHeight
    const newSize = Math.max(200, initialWidth - 32)
    this.resizeBoard(newSize, newSize)
  }

  private enlargeBoard() {
    const initialWidth = this.chessboardEl.clientWidth
    const initialHeight = this.chessboardEl.clientHeight
    const newSize = initialWidth + 32
    this.resizeBoard(newSize, newSize)
  }

  // Cleanup method for proper disposal
  public destroy() {
    if (this.dragHandle && this.chessboardEl.contains(this.dragHandle)) {
      this.chessboardEl.removeChild(this.dragHandle)
    }
    document.removeEventListener('mousemove', this.boundMouseMove)
    document.removeEventListener('mouseup', this.boundMouseUp)
    document.body.style.cursor = ''
    document.body.style.userSelect = ''
  }
}