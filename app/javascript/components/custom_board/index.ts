import Backbone from 'backbone'
import SimpleColorPicker from 'simple-color-picker'

import Chessboard from '../chessboard/chessboard'
import d from '../../dispatcher'

const defaultColors = {
  light: '#f3e4cf',
  dark: '#ceb3a2',
  from: '#fffcdd',
  to: '#fff79b',
  selected: '#eeffff',
}

class BoardStyles extends Backbone.Model {
  public css(): string {
    let css = ""
    if (this.get(`light`)) {
     css += `.chessboard .square.light { background: ${this.get(`light`)} !important; }`
    }
    if (this.get(`dark`)) {
     css += `.chessboard .square.dark { background: ${this.get(`dark`)} !important; }`
    }
    if (this.get(`from`)) {
     css += `.chessboard .square[data-from] { background: ${this.get(`from`)} !important; }`
    }
    if (this.get(`to`)) {
     css += `.chessboard .square[data-to] { background: ${this.get(`to`)} !important; }`
    }
    if (this.get(`selected`)) {
     css += `.chessboard .square[data-selected] { background: ${this.get(`selected`)} !important; }`
    }
    return css
  }
}

export default class CustomBoard extends Backbone.View<Backbone.Model> {
  // private boardStyles: BoardStyles
  private colorPicker: SimpleColorPicker

  get el(): HTMLElement {
    return document.querySelector('.customize-board')
  }

  private get styleEl(): HTMLElement {
    return this.el.querySelector(`style`)
  }

  events(): Backbone.EventsHash {
    return {
      'click .square-color .square':  '_toggleColorPicker',
      'keyup .hex':                   '_textInputColor',
      'click .reset-colors':          '_resetColors',
      'click .save-colors':           '_saveColors',
    }
  }

  initialize() {
    new Chessboard()
    d.trigger(`fen:set`, `1Q6/8/8/8/8/2K5/k7/8 b - - 13 62`)
    d.trigger(`move:highlight`, { from: `a3`, to: `a2` })
    const squares = ['light', 'dark', 'selected', 'from', 'to']
    const initialColors = {}
    squares.forEach(squareType => {
      const colorInputEl = this.squareColorInputEl(squareType)
      const color = colorInputEl.value || defaultColors[squareType]
      initialColors[squareType] = color
    })
    this.boardStyles = new BoardStyles()
    this.listenTo(this.boardStyles, `change`, () => {
      Object.entries(this.boardStyles.changedAttributes()).forEach(([sqType, color]) => {
        this.squareColorInputEl(sqType).value = <string>color
        this.squareEl(sqType).style.background = <string>color
      })
      this.styleEl.textContent = this.boardStyles.css()
    })
    this.boardStyles.set(initialColors)
  }

  private squareColorInputEl(sq: string): HTMLInputElement {
    return this.el.querySelector(`.squares .square-color.${sq} input`)
  }

  private squareEl(sq: string): HTMLElement {
    return this.el.querySelector(`.squares .square-color.${sq} .square`)
  }

  private setElementColors(squareType: string, colorHex: string) {
  }

  private _toggleColorPicker(e) {
    if (this.colorPicker) {
      this.colorPicker.remove()
    }
    const squareEl = e.target
    this.colorPicker = new SimpleColorPicker({
      color: squareEl.style.background,
      el: e.currentTarget,
    });
    (<any>this.colorPicker).on('update', () => {
      const color = this.colorPicker.getHexString()
      this.boardStyles.set(squareEl.dataset.sq, color)
    })
  }

  private _textInputColor(e) {
    const colorInputEl = e.target
    const squareEl = colorInputEl.previousSibling
    console.log(`setting color for ${squareEl.dataset.sq}`)
  }

  private _resetColors() {
    this.boardStyles.set(defaultColors)
  }

  private _saveColors() {
    console.log('saving colors')
  }
}
