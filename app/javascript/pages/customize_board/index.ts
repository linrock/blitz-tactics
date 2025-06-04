import SimpleColorPicker from 'simple-color-picker'

import { dispatch } from '@blitz/events'
import BoardStyles from './board_styles'

import ChessgroundBoard from '@blitz/components/chessground_board'
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

  private get styleEl(): HTMLElement {
    return this.el.querySelector(`style`)
  }

  private initialize() {
    new ChessgroundBoard({ fen: '1Q6/8/8/8/8/k1K5/8/8 b - - 13 62', viewOnly: true })
    setTimeout(() => {
      dispatch('move:make', 'Ka2', { opponent: true })
      setTimeout(() => {
        const highlightEl = document.createElement('square')
        highlightEl.classList.add('selected')
        highlightEl.style.transform = 'translate(60px, 0)'
        document.querySelector('cg-board').appendChild(highlightEl)
      }, 200)
    }, 500)
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
  }
}
