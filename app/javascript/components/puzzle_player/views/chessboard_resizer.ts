const boardSelector = '.chessground-board'

export default class ChessboardResizer {
  private chessboardEl: HTMLElement
  private dragHandle: HTMLElement
  private isDragging: boolean = false
  private startX: number = 0
  private startY: number = 0
  private startWidth: number = 0
  private startHeight: number = 0
  private lastUpdateTime: number = 0

  // Bound event handlers for easy cleanup
  private boundMouseMove: (e: MouseEvent) => void
  private boundMouseUp: (e: MouseEvent) => void

  constructor() {
    this.chessboardEl = document.querySelector(boardSelector)
    
    // Bind event handlers
    this.boundMouseMove = this.handleMouseMove.bind(this)
    this.boundMouseUp = this.handleMouseUp.bind(this)
    
    if (this.chessboardEl) {
      this.createDragHandle()
      this.setupDragEventListeners()
    } else {
      console.warn(`chessboard_resizer: failed to find ${boardSelector}`)
    }
  }

  private snapToMultipleOf8(size: number): number {
    return Math.round(size / 8) * 8
  }

  private getMaxBoardSize(): number {
    // Leave some padding around the board (40px on each side for margins/padding)
    const viewportPadding = 80
    const maxWidth = window.innerWidth - viewportPadding
    const maxHeight = window.innerHeight - viewportPadding
    
    // Use the smaller dimension since the board is square
    const maxSize = Math.min(maxWidth, maxHeight)
    
    // Snap to multiple of 8 and ensure it's at least the minimum size
    return Math.max(200, this.snapToMultipleOf8(maxSize))
  }

  private createDragHandle() {
    // Create the drag handle element
    this.dragHandle = document.createElement('div')
    this.dragHandle.className = 'chessboard-drag-handle'
    this.dragHandle.innerHTML = '⋰' // Resize icon
    this.dragHandle.title = 'Drag to resize board'
    
    // The chessboard already has absolute positioning from CSS, don't override it
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
    document.body.style.cursor = 'nwse-resize'
    document.body.style.userSelect = 'none'
  }

  private handleMouseMove(e: MouseEvent) {
    if (!this.isDragging) return
    
    e.preventDefault()
    
    const deltaX = e.clientX - this.startX
    const deltaY = e.clientY - this.startY
    
    // Use the larger of the two deltas to maintain square aspect ratio
    const delta = Math.max(deltaX, deltaY)
    const rawSize = Math.max(200, this.startWidth + delta) // Minimum size of 200px
    const maxSize = this.getMaxBoardSize()
    const constrainedSize = Math.min(rawSize, maxSize) // Don't exceed viewport
    const newSize = this.snapToMultipleOf8(constrainedSize) // Snap to multiples of 8px
    
    // Update the chessboard size and UI positioning during drag
    this.chessboardEl.style.width = `${newSize}px`
    this.chessboardEl.style.height = `${newSize}px`
    
    // Update all container elements in real-time for smooth movement
    const boardAreaEl: HTMLElement = document.querySelector('.board-area')
    const boardAreaContainerEl: HTMLElement = document.querySelector('.board-area-container')
    const aboveBoardEl: HTMLElement = document.querySelector('.above-board')
    const containerEl: HTMLElement = document.querySelector('.game-mode .container')

    if (boardAreaEl) {
      boardAreaEl.style.width = `${newSize}px`
      boardAreaEl.style.height = `${newSize}px`
    }

    if (boardAreaContainerEl) {
      boardAreaContainerEl.style.width = `${newSize}px`
    }
    
    if (aboveBoardEl) {
      aboveBoardEl.style.width = `${newSize}px`
    }
    
    // Update UI positioning in real-time during drag
    if (containerEl) {
      const topOffset = 64 // Fixed top position of board
      const aboveBoardHeight = 20 // Margin between board and above-board content
      const totalOffset = topOffset + newSize + aboveBoardHeight
      containerEl.style.paddingTop = `${totalOffset}px`
    }
  }

  private handleMouseUp(e: MouseEvent) {
    if (!this.isDragging) return
    
    this.isDragging = false
    this.dragHandle.classList.remove('dragging')
    document.body.style.cursor = ''
    document.body.style.userSelect = ''
    
    // Now update all container elements to match the new board size
    const currentSize = this.chessboardEl.clientWidth
    this.updateAllContainers(currentSize)
  }

  private updateAllContainers(size: number) {
    const boardAreaEl: HTMLElement = document.querySelector('.board-area')
    const boardAreaContainerEl: HTMLElement = document.querySelector('.board-area-container')
    const aboveBoardEl: HTMLElement = document.querySelector('.above-board')
    const containerEl: HTMLElement = document.querySelector('.game-mode .container')

    // Update all containers to match the new board size
    if (boardAreaEl) {
      boardAreaEl.style.width = `${size}px`
      boardAreaEl.style.height = `${size}px`
    }

    if (boardAreaContainerEl) {
      boardAreaContainerEl.style.width = `${size}px`
    }
    
    if (aboveBoardEl) {
      aboveBoardEl.style.width = `${size}px`
    }

    // Update container padding to position UI elements correctly based on board size
    if (containerEl) {
      const topOffset = 64 // Fixed top position of board
      const aboveBoardHeight = 20 // Margin between board and above-board content
      const totalOffset = topOffset + size + aboveBoardHeight
      containerEl.style.paddingTop = `${totalOffset}px`
    }
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