import tinycolor from 'tinycolor2'

type EventCallback = () => void

export default class BoardStyles {
  private attributes: Record<string, string> = {}
  private changedAttrs: Record<string, string> = {}
  private listeners: Record<string, EventCallback[]> = {}

  public set(attrs: Record<string, string>) {
    this.changedAttrs = {}
    let hasChanges = false

    Object.entries(attrs).forEach(([key, value]) => {
      if (this.attributes[key] !== value) {
        this.attributes[key] = value
        this.changedAttrs[key] = value
        hasChanges = true
      }
    })

    if (hasChanges) {
      this.trigger('change')
    }
  }

  public changedAttributes(): Record<string, string> {
    return { ...this.changedAttrs }
  }

  public setColor(squareType: string, color: string) {
    const colorHex = tinycolor(color).toHexString().toUpperCase()
    this.set({ [squareType]: colorHex })
  }

  public on(event: string, callback: EventCallback) {
    if (!this.listeners[event]) {
      this.listeners[event] = []
    }
    this.listeners[event].push(callback)
  }

  private trigger(event: string) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(callback => callback())
    }
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
      // Use CSS custom properties for board colors
      css += `:root { --chessboard-light: ${light || '#F3E4CF'}; --chessboard-dark: ${dark || '#CEB3A2'}; }`
      css += `cg-board::before { 
        background-image: conic-gradient(var(--chessboard-dark) 0deg, var(--chessboard-dark) 90deg, var(--chessboard-light) 90deg, var(--chessboard-light) 180deg, var(--chessboard-dark) 180deg, var(--chessboard-dark) 270deg, var(--chessboard-light) 270deg, var(--chessboard-light) 360deg);
        background-size: 25% 25%;
      }`
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
