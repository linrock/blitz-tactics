const boardSelector = '.chessground-board'
const BOARD_SIZE_STORAGE_KEY = 'blitz-tactics-board-size'

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
      // Load and apply saved board size
      this.loadSavedBoardSize()
    } else {
      console.warn(`chessboard_resizer: failed to find ${boardSelector}`)
    }
  }

  private saveBoardSize(size: number) {
    try {
      localStorage.setItem(BOARD_SIZE_STORAGE_KEY, size.toString())
    } catch (e) {
      console.warn('Failed to save board size to localStorage:', e)
    }
  }

  private loadSavedBoardSize() {
    try {
      const savedSize = localStorage.getItem(BOARD_SIZE_STORAGE_KEY)
      if (savedSize) {
        const size = parseInt(savedSize, 10)
        if (size >= 200 && size <= this.getMaxBoardSize()) {
          this.applyBoardSize(size)
        }
      }
    } catch (e) {
      console.warn('Failed to load board size from localStorage:', e)
    }
  }

  private applyBoardSize(size: number) {
    // Apply the size to the chessboard
    this.chessboardEl.style.width = `${size}px`
    this.chessboardEl.style.height = `${size}px`
    
    // Update all containers to match
    this.updateAllContainers(size)
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
    this.dragHandle.innerHTML = `
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 18 18">
        <path fill="#494c4e" d="M14.228 16.227a1 1 0 0 1-.707-1.707l1-1a1 1 0 0 1 1.416 1.414l-1 1a1 1 0 0 1-.707.293zm-5.638 0a1 1 0 0 1-.707-1.707l6.638-6.638a1 1 0 0 1 1.416 1.414l-6.638 6.638a1 1 0 0 1-.707.293zm-5.84 0a1 1 0 0 1-.707-1.707L14.52 2.043a1 1 0 1 1 1.415 1.414L3.457 15.934a1 1 0 0 1-.707.293z"/>
      </svg>
    `
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
    
    // Update the chessboard size during drag
    this.chessboardEl.style.width = `${newSize}px`
    this.chessboardEl.style.height = `${newSize}px`
    
    // Update all container elements in real-time for smooth movement
    const boardAreaEl: HTMLElement = document.querySelector('.board-area')
    const belowBoardEl: HTMLElement = document.querySelector('.below-board')

    if (boardAreaEl) {
      boardAreaEl.style.width = `${newSize}px`
      boardAreaEl.style.height = `${newSize}px`
    }
    
    if (belowBoardEl) {
      belowBoardEl.style.width = `${newSize}px`
    }
    
    // Save the new size to localStorage
    this.saveBoardSize(newSize)
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
    
    // Save the final size to localStorage
    this.saveBoardSize(currentSize)
  }

  private updateAllContainers(size: number) {
    const boardAreaEl: HTMLElement = document.querySelector('.board-area')
    const belowBoardEl: HTMLElement = document.querySelector('.below-board')

    // Update all containers to match the new board size
    if (boardAreaEl) {
      boardAreaEl.style.width = `${size}px`
      boardAreaEl.style.height = `${size}px`
    }
    
    if (belowBoardEl) {
      belowBoardEl.style.width = `${size}px`
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