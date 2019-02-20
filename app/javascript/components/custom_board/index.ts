import Backbone from 'backbone'
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
  get el() {
    return document.querySelector('.custom-board')
  }

  events(): Backbone.EventsHash {
    return {
      'click .square-color':  '_chooseColor',
      'keyup .hex':           '_setColor',
      'click .reset-colors':  '_resetColors',
      'click .save-colors':   '_saveColors',
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
      const color = defaultColors[square]
      this.squareColorInput(square).value = color
      this.square(square).style.background = color
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

  private _chooseColor() {
    console.log('choosing color')
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
