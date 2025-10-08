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
      // Apply to the actual chess square divs
      css += `.chess-square.light { background-color: ${light} !important; }`
    }
    if (dark) {
      css += `.cg-wrap.orientation-white coords.ranks coord:nth-child(2n) { color: ${dark} !important; }`
      css += `.cg-wrap.orientation-white coords.files coord:nth-child(2n) { color: ${dark} !important; }`
      css += `.cg-wrap.orientation-black coords.ranks coord:nth-child(2n + 1) { color: ${dark} !important; }`
      css += `.cg-wrap.orientation-black coords.files coord:nth-child(2n + 1) { color: ${dark} !important; }`
      // Apply to the actual chess square divs
      css += `.chess-square.dark { background-color: ${dark} !important; }`
    }
    if (from) {
      css += `.chess-square.move-from { background-color: ${from} !important; }`
    }
    if (to) {
      css += `.chess-square.move-to { background-color: ${to} !important; }`
    }
    if (selected) {
      css += `.chess-square.selected { background: ${selected} !important; }`
    }
    return css
  }
}
