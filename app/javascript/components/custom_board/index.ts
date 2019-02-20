import Backbone from 'backbone'
import SimpleColorPicker from 'simple-color-picker'

import Chessboard from '../chessboard/chessboard'
import d from '../../dispatcher'

const defaultColors = {
  light: '#f3e4cf',
  dark: '#ceb3a2',
  selected: '#eeffff',
  from: '#fffcdd',
  to: '#fff79b',
}

export default class CustomBoard extends Backbone.View<Backbone.Model> {
  private colorPicker: SimpleColorPicker

  get el() {
    return document.querySelector('.custom-board')
  }

  events(): Backbone.EventsHash {
    return {
      'click .square-color .square':  '_toggleColorPicker',
      'keyup .hex':                   '_setColor',
      'click .reset-colors':          '_resetColors',
      'click .save-colors':           '_saveColors',
    }
  }

  get selectorMap() {
    return {
      '.squares-color .square.light': '.chessboard .square.light',
      '.squares-color .square.dark':  '.chessboard .square.dark'
    }
  }

  initialize() {
    new Chessboard()
    d.trigger(`fen:set`, `1Q6/8/8/8/8/2K5/k7/8 b - - 13 62`)
    d.trigger(`move:highlight`, { from: `a3`, to: `a2` })
    const squares = ['light', 'dark', 'selected', 'from', 'to']
    squares.forEach(square => {
      const colorInputEl = this.squareColorInput(square)
      const colorSquareEl = this.square(square)
      const color = colorInputEl.value || defaultColors[square]
      colorInputEl.value = color
      colorSquareEl.style.background = color
    })
  }

  private squareColorInput(sq: string): HTMLInputElement {
    return this.el.querySelector(`.squares .square-color.${sq} input`)
  }

  private square(sq: string): HTMLElement {
    return this.el.querySelector(`.squares .square-color.${sq} .square`)
  }

  private getColor(cssSelector: string): string {
    const el = document.querySelector(cssSelector)
    return getComputedStyle(el).backgroundColor
  }

  private _toggleColorPicker(e) {
    if (this.colorPicker) {
      this.colorPicker.remove()
      this.colorPicker = null
    }
    const squareEl = e.target
    const colorInputEl = squareEl.nextSibling
    this.colorPicker = new SimpleColorPicker({
      color: squareEl.style.background,
      el: e.currentTarget,
    })
    this.colorPicker.on('update', () => {
      const color = this.colorPicker.getHexString()
      colorInputEl.value = color
      squareEl.style.background = color
    })
  }

  private _setColor(e) {
    e.currentTarget
    console.log('setting color')
  }

  private _resetColors() {
    console.log('resetting colors')
  }

  private _saveColors() {
    console.log('saving colors')
  }
}
