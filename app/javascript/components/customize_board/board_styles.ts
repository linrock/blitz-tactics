import Backbone from 'backbone'
import tinycolor from 'tinycolor2'

export default class BoardStyles extends Backbone.Model {
  public setColor(squareType: string, color: string) {
    const colorHex = tinycolor(color).toHexString().toUpperCase()
    this.set(squareType, colorHex)
  }

  public css(): string {
    const { light, dark, from, to, selected } = this.attributes
    let css = ""
    if (light) {
      css += `.chessboard .square.light { background: ${light} !important; }`
      css += `.chessboard .square .square-label.dark { color: ${light} !important; }`
    }
    if (dark) {
      css += `.chessboard .square.dark { background: ${dark} !important; }`
      css += `.chessboard .square .square-label.light { color: ${dark} !important; }`
    }
    if (from) {
      css += `.chessboard .square[data-from] { background: ${from} !important; }`
    }
    if (to) {
      css += `.chessboard .square[data-to] { background: ${to} !important; }`
    }
    if (selected) {
      css += `.chessboard .square[data-selected] { background: ${selected} !important; }`
    }
    return css
  }
}
