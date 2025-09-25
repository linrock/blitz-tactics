const BOARD_SIZE_STORAGE_KEY = 'blitz-tactics-position-trainer-board-size'
const MIN_BOARD_SIZE = 200
const MAX_BOARD_SIZE = 600
const DEFAULT_BOARD_SIZE = 400

export default class PositionTrainerResizer {
  private boardEl: HTMLElement
  private dragHandle: HTMLElement
  private isDragging: boolean = false
  private startX: number = 0
  private startY: number = 0
  private startSize: number = 0
  private lastUpdateTime: number = 0

  // Bound event handlers for easy cleanup
  private boundMouseMove: (e: MouseEvent) => void
  private boundMouseUp: (e: MouseEvent) => void
  private boundWindowResize: () => void

  constructor(selector = '.chessground-board') {
    this.boardEl = document.querySelector(selector)
    
    // Bind event handlers
    this.boundMouseMove = this.handleMouseMove.bind(this)
    this.boundMouseUp = this.handleMouseUp.bind(this)
    this.boundWindowResize = this.handleWindowResize.bind(this)
    
    if (this.boardEl) {
      this.createDragHandle()
      this.setupDragEventListeners()
      // Load and apply saved board size
      this.loadSavedBoardSize()
    } else {
      console.warn(`position_trainer_resizer: failed to find ${selector}`)
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
        if (size >= MIN_BOARD_SIZE && size <= MAX_BOARD_SIZE) {
          this.resizeBoard(size)
        }
      } else {
        // Set default size
        this.resizeBoard(DEFAULT_BOARD_SIZE)
      }
    } catch (e) {
      console.warn('Failed to load board size from localStorage:', e)
      this.resizeBoard(DEFAULT_BOARD_SIZE)
    }
  }

  private getMaxBoardSize(): number {
    return Math.min(window.innerWidth * 0.8, window.innerHeight * 0.6, MAX_BOARD_SIZE)
  }

  private createDragHandle() {
    // Create the drag handle element
    this.dragHandle = document.createElement('div')
    this.dragHandle.className = 'position-trainer-resizer'
    this.dragHandle.innerHTML = `
      <svg class="resizer-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="m21 15-6 6m6-13-13 13" stroke="#636363" stroke-linecap="round" stroke-linejoin="round" stroke-width="2"/>
      </svg>
    `
    
    // Add styles
    this.dragHandle.style.cssText = `
      position: absolute;
      bottom: -4px;
      right: -4px;
      width: 24px;
      height: 24px;
      background: transparent;
      cursor: nwse-resize;
      z-index: 10;
      display: flex;
      align-items: center;
      justify-content: center;
      border-radius: 20px;
    `
    
    this.dragHandle.querySelector('.resizer-icon').style.cssText = `
      width: 20px;
      height: 20px;
      stroke: #636363;
    `
    
    // Add hover effect
    this.dragHandle.addEventListener('mouseenter', () => {
      this.dragHandle.style.background = 'rgba(255, 255, 255, 0.1)'
    })
    
    this.dragHandle.addEventListener('mouseleave', () => {
      this.dragHandle.style.background = 'transparent'
    })
    
    // Make the board element itself relative positioned and append the resizer to it
    this.boardEl.style.position = 'relative'
    this.boardEl.appendChild(this.dragHandle)
  }

  private setupDragEventListeners() {
    this.dragHandle.addEventListener('mousedown', (e) => {
      e.preventDefault()
      this.isDragging = true
      this.startX = e.clientX
      this.startY = e.clientY
      this.startSize = parseInt(this.boardEl.style.width) || DEFAULT_BOARD_SIZE
      
      document.addEventListener('mousemove', this.boundMouseMove)
      document.addEventListener('mouseup', this.boundMouseUp)
    })
  }

  private handleMouseMove(e: MouseEvent) {
    if (!this.isDragging) return

    const now = Date.now()
    if (now - this.lastUpdateTime < 16) return // ~60fps
    this.lastUpdateTime = now

    const deltaX = e.clientX - this.startX
    const deltaY = e.clientY - this.startY
    const delta = Math.max(deltaX, deltaY)
    
    const newSize = Math.max(MIN_BOARD_SIZE, Math.min(this.getMaxBoardSize(), this.startSize + delta))
    this.resizeBoard(newSize)
  }

  private handleMouseUp() {
    if (this.isDragging) {
      this.isDragging = false
      this.saveBoardSize(parseInt(this.boardEl.style.width))
    }

    document.removeEventListener('mousemove', this.boundMouseMove)
    document.removeEventListener('mouseup', this.boundMouseUp)
  }

  private handleWindowResize() {
    const currentSize = parseInt(this.boardEl.style.width)
    if (currentSize > this.getMaxBoardSize()) {
      this.resizeBoard(this.getMaxBoardSize())
    }
  }

  private resizeBoard(size: number) {
    this.boardEl.style.width = `${size}px`
    this.boardEl.style.height = `${size}px`
    
    // Also resize the chessground wrapper if it exists
    const cgWrap = this.boardEl.querySelector('.cg-wrap')
    if (cgWrap) {
      cgWrap.style.width = `${size}px`
      cgWrap.style.height = `${size}px`
    }
  }

  public destroy() {
    if (this.dragHandle && this.dragHandle.parentElement) {
      this.dragHandle.parentElement.removeChild(this.dragHandle)
    }
    
    document.removeEventListener('mousemove', this.boundMouseMove)
    document.removeEventListener('mouseup', this.boundMouseUp)
    window.removeEventListener('resize', this.boundWindowResize)
  }
}
