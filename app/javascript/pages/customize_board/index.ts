import SimpleColorPicker from 'simple-color-picker'

import ChessgroundBoard from '@blitz/components/chessground_board'
import { dispatch } from '@blitz/events'

import BoardStyles from './board_styles'
import '../../../../vendor/assets/stylesheets/simple-color-picker.css'
import './style.sass'

const defaultColors = {
  light: '#F3E4CF',
  dark: '#CEB3A2',
  from: '#FFFCDD',
  to: '#FFF79B',
  selected: '#EEFFFF',
}

const boardStyles = new BoardStyles()

export default class CustomizeBoard {
  private colorPicker: any
  private el: HTMLElement

  constructor() {
    this.el = document.querySelector('.customize-board')
    this.initialize()
    this.setupEventListeners()
  }

  private initializePieceSetPreviews() {
    // Piece preview images are now set server-side via Rails asset helpers
    // This method is kept for any future client-side preview functionality
  }

  private get styleEl(): HTMLElement {
    return this.el.querySelector(`style`)
  }

  private initialize() {
    // Use puzzle data if available, otherwise fallback to default position
    const puzzleData = (window as any).hastePuzzleData
    const fen = puzzleData ? puzzleData.fen : '1Q6/8/8/8/8/k1K5/8/8 b - - 13 62'
    
    new ChessgroundBoard({ fen, viewOnly: true })
    
    // If we have puzzle data, add highlighting without making moves
    if (puzzleData && puzzleData.initialMove && puzzleData.initialMove.uci) {
      const firstMove = puzzleData.initialMove.uci
      setTimeout(() => {
        this.addPuzzleHighlighting(firstMove, puzzleData.lines)
      }, 500)
    } else {
      // Default behavior for fallback position
      setTimeout(() => {
        this.addDefaultHighlighting()
      }, 500)
    }
    
    // Initialize piece set previews
    this.initializePieceSetPreviews()
    
    // Set initial piece set preview
    const selectedPieceSet = this.el.querySelector('input[name="board[piece_set]"]:checked') as HTMLInputElement
    if (selectedPieceSet) {
      this._updateBoardPieceSet(selectedPieceSet.value)
    }
    
    const squares = ['light', 'dark', 'selected', 'from', 'to']
    const initialColors = {}
    squares.forEach(squareType => {
      const colorInputEl = this.squareColorInputEl(squareType)
      const color = colorInputEl.value || defaultColors[squareType]
      initialColors[squareType] = color
    })
    
    // Listen to board styles changes
    boardStyles.on('change', () => {
      Object.entries(boardStyles.changedAttributes()).forEach(([sqType, color]) => {
        this.squareColorInputEl(sqType).value = color as string
        this.squareEl(sqType).style.background = color as string
      })
      this.styleEl.textContent = boardStyles.css()
    })
    
    boardStyles.set(initialColors)
  }

  private getSquareIndex(square: string): number {
    const file = square.charCodeAt(0) - 97 // 'a' = 97
    const rank = parseInt(square[1]) - 1
    return rank * 8 + file
  }

  private getSquareCoordinates(index: number): [number, number] {
    const file = index % 8
    const rank = 7 - Math.floor(index / 8) // Flip rank for display
    return [file, rank]
  }

  private addPuzzleHighlighting(firstMove: string, lines: any) {
    const board = document.querySelector('cg-board')
    if (!board) return

    // For preview purposes, show where a move would come from/to
    const fromSquare = firstMove.slice(0, 2)
    const toSquare = firstMove.slice(2, 4)
    
    // Create "from" highlight to show where the piece would move from
    const fromEl = document.createElement('square')
    fromEl.classList.add('last-move', 'move-from')
    const fromIndex = this.getSquareIndex(fromSquare)
    const [fromX, fromY] = this.getSquareCoordinates(fromIndex)
    fromEl.style.transform = `translate(${fromX * 60}px, ${fromY * 60}px)`
    board.appendChild(fromEl)

    // Create "to" highlight to show where the piece would move to
    const toEl = document.createElement('square')
    toEl.classList.add('last-move', 'move-to')
    const toIndex = this.getSquareIndex(toSquare)
    const [toX, toY] = this.getSquareCoordinates(toIndex)
    toEl.style.transform = `translate(${toX * 60}px, ${toY * 60}px)`
    board.appendChild(toEl)

    // Add selected highlighting for the piece that could move next
    if (lines && Object.keys(lines).length > 0) {
      // Find the first player move in the lines tree
      const playerMove = Object.keys(lines)[0]
      if (playerMove) {
        const playerFromSquare = playerMove.slice(0, 2)
        const selectedEl = document.createElement('square')
        selectedEl.classList.add('selected')
        const selectedIndex = this.getSquareIndex(playerFromSquare)
        const [selectedX, selectedY] = this.getSquareCoordinates(selectedIndex)
        selectedEl.style.transform = `translate(${selectedX * 60}px, ${selectedY * 60}px)`
        board.appendChild(selectedEl)
      }
    }
  }

  private addDefaultHighlighting() {
    const board = document.querySelector('cg-board')
    if (!board) return
    
    // Default selected highlighting (fallback position)
    const highlightEl = document.createElement('square')
    highlightEl.classList.add('selected')
    highlightEl.style.transform = 'translate(60px, 0)'
    board.appendChild(highlightEl)
  }

  private setupEventListeners() {
    // Set up click handlers for square color toggles
    this.el.addEventListener('click', (e) => {
      const target = e.target as HTMLElement
      if (target.matches('.square-color .square')) {
        this._toggleColorPicker(e)
      } else if (target.matches('.reset-colors')) {
        this._resetColors(e)
      }
    })

    // Set up piece set change handler
    this.el.addEventListener('change', (e) => {
      const target = e.target as HTMLElement
      if (target.matches('input[name="board[piece_set]"]')) {
        this._updatePieceSetPreview(e as Event & { target: HTMLInputElement })
      }
    })

    // Set up click handler for piece set options
    this.el.addEventListener('click', (e) => {
      const target = e.target as HTMLElement
      // Check if click is on piece set option area
      const pieceSetOption = target.closest('.piece-set-option')
      if (pieceSetOption) {
        const radioButton = pieceSetOption.querySelector('input[name="board[piece_set]"]') as HTMLInputElement
        if (radioButton && !radioButton.checked) {
          radioButton.checked = true
          this._updatePieceSetPreview({ target: radioButton } as Event & { target: HTMLInputElement })
        }
      }
    })

    // Set up keypress and keyup handlers for hex inputs
    this.el.addEventListener('keypress', (e) => {
      const target = e.target as HTMLElement
      if (target.matches('.hex')) {
        this._preventFormSubmit(e as KeyboardEvent)
      }
    })

    this.el.addEventListener('keyup', (e) => {
      const target = e.target as HTMLElement
      if (target.matches('.hex')) {
        this._textInputColor(e as KeyboardEvent)
      }
    })

    // Set up document click handler for closing color picker
    document.addEventListener('click', (e) => {
      let node = e.target as HTMLElement
      while (node) {
        if (node.classList.contains('square-color')) {
          return
        }
        node = node.parentElement
      }
      this.removeColorPicker()
    })
  }

  private squareColorInputEl(sq: string): HTMLInputElement {
    return this.el.querySelector(`.squares .square-color.${sq} input`)
  }

  private squareEl(sq: string): HTMLElement {
    return this.el.querySelector(`.squares .square-color.${sq} .square`)
  }

  private removeColorPicker() {
    if (this.colorPicker) {
      this.colorPicker.$el.parentNode.classList.add('invisible')
      this.colorPicker.remove()
      this.colorPicker = null
    }
  }

  private _toggleColorPicker(e: Event) {
    this.removeColorPicker()
    const squareEl = e.target as HTMLElement
    const colorPickerContainerEl = squareEl.previousSibling as HTMLElement
    this.colorPicker = new SimpleColorPicker({
      color: squareEl.style.background,
      el: colorPickerContainerEl,
    })
    colorPickerContainerEl.classList.remove('invisible')
    this.colorPicker.on('update', () => {
      const color = this.colorPicker.getHexString()
      boardStyles.setColor(squareEl.dataset.sq, color)
    })
  }

  private _textInputColor(e: KeyboardEvent) {
    const colorInputEl = e.target as HTMLInputElement
    const colorText = colorInputEl.value
    const squareEl = colorInputEl.previousSibling as HTMLElement
    if (e.which === 13 || colorText.length >= 6) {
      boardStyles.setColor(squareEl.dataset.sq, colorText)
    }
  }

  private _preventFormSubmit(e: KeyboardEvent) {
    if (e.which === 13) {
      e.preventDefault()
      e.stopImmediatePropagation()
      return false
    }
  }

  private _resetColors(e: Event) {
    e.preventDefault()
    boardStyles.set(defaultColors)
    
    // Reset piece set to default (cburnett)
    const defaultPieceSetRadio = this.el.querySelector('input[name="board[piece_set]"][value="cburnett"]') as HTMLInputElement
    if (defaultPieceSetRadio) {
      defaultPieceSetRadio.checked = true
      // Update the piece set preview
      this._updateBoardPieceSet('cburnett')
    }
  }

  private _updatePieceSetPreview(e: Event & { target: HTMLInputElement }) {
    const pieceSet = e.target.value
    this._updateBoardPieceSet(pieceSet)
  }

  private _updateBoardPieceSet(pieceSet: string) {
    // Find the SVG container for this piece set
    const pieceSetContainer = document.querySelector(`.piece-set-svgs[data-piece-set="${pieceSet}"]`)
    if (!pieceSetContainer) {
      console.warn(`No SVG container found for piece set: ${pieceSet}`)
      return
    }
    
    // Update all pieces on the board
    const pieces = ['wK', 'wQ', 'wR', 'wB', 'wN', 'wP', 'bK', 'bQ', 'bR', 'bB', 'bN', 'bP']
    const pieceMap = {
      'wK': 'king.white', 'wQ': 'queen.white', 'wR': 'rook.white', 
      'wB': 'bishop.white', 'wN': 'knight.white', 'wP': 'pawn.white',
      'bK': 'king.black', 'bQ': 'queen.black', 'bR': 'rook.black',
      'bB': 'bishop.black', 'bN': 'knight.black', 'bP': 'pawn.black'
    }
    
    pieces.forEach(pieceCode => {
      const svgElement = pieceSetContainer.querySelector(`.piece-svg[data-piece="${pieceCode}"]`)
      const pieceClass = pieceMap[pieceCode]
      const boardPieces = document.querySelectorAll(`.cg-wrap piece.${pieceClass}`)
      
      if (svgElement && svgElement.innerHTML.trim()) {
        // Update all pieces of this type (there might be multiple pawns, etc.)
        boardPieces.forEach(boardPiece => {
          // Replace the piece's background with the SVG content
          boardPiece.innerHTML = svgElement.innerHTML
          const pieceEl = boardPiece as HTMLElement
          pieceEl.style.backgroundImage = 'none'
          
          // Remove any classes that might cause opacity issues
          pieceEl.classList.remove('fading', 'ghost')
          
          // Ensure full opacity for the piece element itself
          pieceEl.style.opacity = '1'
          
          // Ensure the SVG fills the piece container and has full opacity
          const svg = pieceEl.querySelector('svg')
          if (svg) {
            svg.style.width = '100%'
            svg.style.height = '100%'
            svg.style.display = 'block'
            svg.style.opacity = '1'
            
            // Also ensure any images within the SVG have full opacity
            const images = svg.querySelectorAll('image')
            images.forEach(img => {
              ;(img as unknown as HTMLElement).style.opacity = '1'
            })
          }
        })
      }
    })
  }


}
