import Backbone from 'backbone'
import tinycolor from 'tinycolor2'

export default class BoardStyles extends Backbone.Model {
  public setColor(squareType: string, color: string) {
    const colorHex = tinycolor(color).toHexString().toUpperCase()
    this.set(squareType, colorHex)
  }

  public css(): string {
    const { light, dark, from, to, selected } = this.attributes
    let css = ''
    if (light) {
      css += `.cg-wrap.orientation-white coords.ranks coord:nth-child(2n + 1) { color: ${light} !important; }`
      css += `.cg-wrap.orientation-white coords.files coord:nth-child(2n + 1) { color: ${light} !important; }`
      css += `.cg-wrap.orientation-black coords.ranks coord:nth-child(2n) { color: ${light} !important; }`
      css += `.cg-wrap.orientation-black coords.files coord:nth-child(2n) { color: ${light} !important; }`
    }
    if (dark) {
      css += `.cg-wrap.orientation-white coords.ranks coord:nth-child(2n) { color: ${dark} !important; }`
      css += `.cg-wrap.orientation-white coords.files coord:nth-child(2n) { color: ${dark} !important; }`
      css += `.cg-wrap.orientation-black coords.ranks coord:nth-child(2n + 1) { color: ${dark} !important; }`
      css += `.cg-wrap.orientation-black coords.files coord:nth-child(2n + 1) { color: ${dark} !important; }`
    }
    if (light || dark) {
      const b64Svg = `
        <?xml version="1.0" encoding="UTF-8" standalone="no"?>
        <svg xmlns="http://www.w3.org/2000/svg" xmlns:x="http://www.w3.org/1999/xlink"
            viewBox="0 0 8 8" shape-rendering="crispEdges">
        <g id="a">
          <g id="b">
            <g id="c">
              <g id="d">
                <rect width="1" height="1" fill="${light}" id="e"/>
                <use x="1" y="1" href="#e" x:href="#e"/>
                <rect y="1" width="1" height="1" fill="${dark}" id="f"/>
                <use x="1" y="-1" href="#f" x:href="#f"/>
              </g>
              <use x="2" href="#d" x:href="#d"/>
            </g>
            <use x="4" href="#c" x:href="#c"/>
          </g>
          <use y="2" href="#b" x:href="#b"/>
        </g>
        <use y="4" href="#a" x:href="#a"/>
        </svg>
      `.trim()
      css += `cg-board { background-image: url('data:image/svg+xml;base64,${btoa(b64Svg)}'); }`
    }
    if (from) {
      css += `cg-board square.last-move.move-from { background-color: ${from} !important; }`
    }
    if (to) {
      css += `cg-board square.last-move.move-to { background-color: ${to} !important; }`
    }
    if (selected) {
      css += `cg-board square.selected { background: ${selected} !important; }`
    }
    return css
  }
}
