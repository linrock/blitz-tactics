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

  // Cache DOM elements for better performance
  private boardAreaEl: HTMLElement | null = null
  private belowBoardEl: HTMLElement | null = null
  private rightStatsEl: HTMLElement | null = null

  // Animation frame optimization
  private animationFrameId: number | null = null
  private pendingSize: number | null = null

  // Bound event handlers for easy cleanup
  private boundMouseMove: (e: MouseEvent) => void
  private boundMouseUp: (e: MouseEvent) => void
  private boundWindowResize: () => void

  constructor() {
    this.chessboardEl = document.querySelector(boardSelector)
    
    // Cache DOM elements for better performance
    this.boardAreaEl = document.querySelector('.board-area')
    this.belowBoardEl = document.querySelector('.below-board')
    this.rightStatsEl = document.querySelector('.right-stats')
    
    // Bind event handlers
    this.boundMouseMove = this.handleMouseMove.bind(this)
    this.boundMouseUp = this.handleMouseUp.bind(this)
    this.boundWindowResize = this.handleWindowResize.bind(this)
    
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
    // Apply the size to the chessboard using both inline styles and CSS variables
    this.chessboardEl.style.width = `${size}px`
    this.chessboardEl.style.height = `${size}px`
    
    // Also set the CSS variable to override any CSS rules
    document.documentElement.style.setProperty('--board-size', `${size}px`)
    
    // Update all containers to match
    this.updateAllContainers(size)
  }

  private snapToMultipleOf8(size: number): number {
    return Math.round(size / 8) * 8
  }

  private getMaxBoardSize(): number {
    // Calculate available space by considering actual UI elements
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    
    // Account for header height
    const headerEl = document.querySelector('.main-header')
    const headerHeight = headerEl ? headerEl.getBoundingClientRect().height : 40
    
    // Account for above-board area (if it exists)
    const aboveBoardEl = document.querySelector('.above-board')
    const aboveBoardHeight = aboveBoardEl ? aboveBoardEl.getBoundingClientRect().height : 0
    
    // Account for below-board area (if it exists)
    const belowBoardEl = document.querySelector('.below-board')
    const belowBoardHeight = belowBoardEl ? belowBoardEl.getBoundingClientRect().height : 0
    
    // Account for description section (if it exists - for position trainer)
    const descriptionEl = document.querySelector('.description-section')
    const descriptionHeight = descriptionEl ? descriptionEl.getBoundingClientRect().height : 0
    
    // Account for actions/buttons area (if it exists)
    const actionsEl = document.querySelector('.actions')
    const actionsHeight = actionsEl ? actionsEl.getBoundingClientRect().height : 0
    
    // Calculate available space with some padding
    const horizontalPadding = 40 // 20px on each side
    const verticalPadding = 40 // 20px top and bottom
    
    const maxWidth = viewportWidth - horizontalPadding
    const maxHeight = viewportHeight - headerHeight - aboveBoardHeight - belowBoardHeight - descriptionHeight - actionsHeight - verticalPadding
    
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
    window.addEventListener('resize', this.boundWindowResize)
    
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
    
    // Store the pending size for requestAnimationFrame
    this.pendingSize = newSize
    
    // Use requestAnimationFrame for smooth updates
    if (this.animationFrameId === null) {
      this.animationFrameId = requestAnimationFrame(() => {
        this.updateBoardSize(this.pendingSize!)
        this.animationFrameId = null
        this.pendingSize = null
      })
    }
  }

  private updateBoardSize(newSize: number) {
    // Update the chessboard size during drag
    this.chessboardEl.style.setProperty('width', `${newSize}px`, 'important')
    this.chessboardEl.style.setProperty('height', `${newSize}px`, 'important')
    
    // Also set the CSS variable to override any CSS rules
    document.documentElement.style.setProperty('--board-size', `${newSize}px`)
    
    // Also resize the chessground wrapper if it exists
    const cgWrap = this.chessboardEl.querySelector('.cg-wrap')
    if (cgWrap) {
      cgWrap.style.setProperty('width', `${newSize}px`, 'important')
      cgWrap.style.setProperty('height', `${newSize}px`, 'important')
    }
    
    // Update all container elements in real-time for smooth movement (only if they exist)
    if (this.boardAreaEl) {
      this.boardAreaEl.style.setProperty('width', `${newSize}px`, 'important')
      this.boardAreaEl.style.setProperty('height', `${newSize}px`, 'important')
    }
    
    if (this.belowBoardEl) {
      this.belowBoardEl.style.setProperty('width', `${newSize}px`, 'important')
    }

    // Update repetition mode stats position to follow board resize (only if they exist)
    if (this.rightStatsEl) {
      this.rightStatsEl.style.left = `calc(50% + ${newSize / 2}px + 1rem)`
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

  private handleWindowResize() {
    // When window is resized, ensure board doesn't exceed new viewport constraints
    const currentSize = this.chessboardEl.clientWidth
    const maxSize = this.getMaxBoardSize()
    
    if (currentSize > maxSize) {
      // Board is too large for new viewport, resize it down
      const newSize = maxSize
      this.updateBoardSize(newSize)
    }
    // Note: We don't automatically grow the board when window gets larger
    // to respect user's manual sizing preferences
  }

  private updateAllContainers(size: number) {
    // Update all containers to match the new board size
    if (this.boardAreaEl) {
      this.boardAreaEl.style.width = `${size}px`
      this.boardAreaEl.style.height = `${size}px`
    }
    
    if (this.belowBoardEl) {
      this.belowBoardEl.style.width = `${size}px`
    }

    // Update repetition mode stats position to follow board resize
    if (this.rightStatsEl) {
      this.rightStatsEl.style.left = `calc(50% + ${size / 2}px + 1rem)`
    }
  }

  // Cleanup method for proper disposal
  public destroy() {
    if (this.dragHandle && this.chessboardEl.contains(this.dragHandle)) {
      this.chessboardEl.removeChild(this.dragHandle)
    }
    
    // Cancel any pending animation frame
    if (this.animationFrameId !== null) {
      cancelAnimationFrame(this.animationFrameId)
      this.animationFrameId = null
    }
    
    document.removeEventListener('mousemove', this.boundMouseMove)
    document.removeEventListener('mouseup', this.boundMouseUp)
    window.removeEventListener('resize', this.boundWindowResize)
    document.body.style.cursor = ''
    document.body.style.userSelect = ''
  }
}