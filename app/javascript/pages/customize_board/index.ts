import SimpleColorPicker from 'simple-color-picker'

import PuzzlePlayer from '@blitz/components/puzzle_player'
import ChessgroundBoard from '@blitz/components/chessground_board'
import { dispatch, GameEvent } from '@blitz/events'

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
  private puzzlePlayer: any

  constructor() {
    this.el = document.querySelector('.customize-board')
    this.initialize()
    this.initializePieceSetPreviews()
    this.setupEventListeners()
    
    // Set initial piece set preview
    const selectedPieceSet = this.el.querySelector('input[name="board[piece_set]"]:checked') as HTMLInputElement
    if (selectedPieceSet) {
      this._updateBoardPieceSet(selectedPieceSet.value)
    }
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
    
    // Initialize the puzzle player with the standard chessboard (no resizing)
    this.puzzlePlayer = new PuzzlePlayer({
      noHint: true,
      noCounter: true,
      noCombo: true,
      noResizer: true,
      source: '/haste/puzzles' // Use haste puzzles as source
    })
    
    // Initialize piece set previews
    
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


  private setupEventListeners() {
    // Set up click handlers for square color toggles
    this.el.addEventListener('click', (e) => {
      const target = e.target as HTMLElement
      if (target.matches('.square-color .square')) {
        this._toggleColorPicker(e)
      } else if (target.matches('.reset-colors')) {
        this._resetColors(e)
      } else if (target.matches('.save-colors')) {
        this._saveBoard(e)
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
    
    // Clear any custom piece set styles that were injected
    this._clearCustomPieceSetStyles()
    
    // Reset piece set to default (cburnett)
    const defaultPieceSetRadio = this.el.querySelector('input[name="board[piece_set]"][value="cburnett"]') as HTMLInputElement
    if (defaultPieceSetRadio) {
      defaultPieceSetRadio.checked = true
      // Update the piece set preview
      this._updateBoardPieceSet('cburnett')
    }
  }

  private _saveBoard(e: Event) {
    e.preventDefault()
    
    // Find the form
    const form = this.el.querySelector('form')
    if (form) {
      // Get the selected piece set
      const selectedPieceSet = this.el.querySelector('input[name="board[piece_set]"]:checked') as HTMLInputElement
      
      // Create a hidden input for the piece set if it's not already in the form
      if (selectedPieceSet) {
        // Remove any existing piece set input in the form
        const existingPieceSetInput = form.querySelector('input[name="board[piece_set]"]')
        if (existingPieceSetInput) {
          existingPieceSetInput.remove()
        }
        
        // Create a new hidden input with the selected piece set value
        const pieceSetInput = document.createElement('input')
        pieceSetInput.type = 'hidden'
        pieceSetInput.name = 'board[piece_set]'
        pieceSetInput.value = selectedPieceSet.value
        form.appendChild(pieceSetInput)
      }
      
      // Submit the form
      form.submit()
    }
  }


  private _updatePieceSetPreview(e: Event & { target: HTMLInputElement }) {
    const pieceSet = e.target.value
    this._updateBoardPieceSet(pieceSet)
  }

  private _clearCustomPieceSetStyles() {
    // Remove any custom piece set styles that were injected via JavaScript
    const customStyles = document.querySelectorAll('style[data-custom-piece-set]')
    customStyles.forEach(style => style.remove())
    
    // Also remove any styles that contain piece set CSS
    const allStyles = document.querySelectorAll('style')
    allStyles.forEach(style => {
      const content = style.innerHTML
      if (content.includes('.cg-wrap piece.') && content.includes('background-image: url(\'data:image/svg+xml;base64,')) {
        style.remove()
      }
    })
  }

  private _updateBoardPieceSet(pieceSet: string) {
    // Clear any existing custom piece set styles
    this._clearCustomPieceSetStyles()
    
    // Generate CSS for the selected piece set using base64 SVG data URIs
    this._injectPieceSetCSS(pieceSet)
  }

  private _injectPieceSetCSS(pieceSet: string) {
    // Create a style element for this piece set
    const style = document.createElement('style')
    style.type = 'text/css'
    style.setAttribute('data-custom-piece-set', 'true')
    
    // Generate CSS rules for each piece using base64 SVG data URIs
    const pieces = ['wK', 'wQ', 'wR', 'wB', 'wN', 'wP', 'bK', 'bQ', 'bR', 'bB', 'bN', 'bP']
    const pieceMap = {
      'wK': 'king.white', 'wQ': 'queen.white', 'wR': 'rook.white', 
      'wB': 'bishop.white', 'wN': 'knight.white', 'wP': 'pawn.white',
      'bK': 'king.black', 'bQ': 'queen.black', 'bR': 'rook.black',
      'bB': 'bishop.black', 'bN': 'knight.black', 'bP': 'pawn.black'
    }
    
    let css = ''
    pieces.forEach(pieceCode => {
      const pieceClass = pieceMap[pieceCode]
      // Get the SVG content from the piece set container
      const pieceSetContainer = document.querySelector(`.piece-set-svgs[data-piece-set="${pieceSet}"]`)
      if (pieceSetContainer) {
        const svgElement = pieceSetContainer.querySelector(`.piece-svg[data-piece="${pieceCode}"]`)
        if (svgElement && svgElement.innerHTML.trim()) {
          // Convert SVG to base64 data URI
          const svgContent = svgElement.innerHTML.trim()
          const base64Svg = btoa(unescape(encodeURIComponent(svgContent)))
          const dataUri = `data:image/svg+xml;base64,${base64Svg}`
          
          // Generate CSS rule
          css += `.cg-wrap piece.${pieceClass} { background-image: url('${dataUri}') !important; background-size: cover !important; background-repeat: no-repeat !important; background-position: center !important; }\n`
        }
      }
    })
    
    style.innerHTML = css
    document.head.appendChild(style)
  }



}
