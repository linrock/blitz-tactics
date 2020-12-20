// instructions above the board for what to do in this position

import { subscribe } from '@blitz/events'
import { FEN } from '@blitz/types'
import { getConfig } from '@blitz/utils'

interface InstructionsOptions {
  fen?: FEN
}

export default class Instructions {
  private initialFen: FEN

  get el(): HTMLElement {
    return document.querySelector(`.instructions`)
  }

  constructor(options: InstructionsOptions = {}) {
    this.initialFen = options.fen
    this.showInstructions()
    subscribe({
      'position:reset': () => this.showInstructions(),
      'game:over': result => this.gameOverMan(result),
      'move:try': () => this.el.classList.add('invisible'),
    })
  }

  get toMove(): 'White' | 'Black' {
    return this.initialFen.indexOf('w') > 0 ? 'White' : 'Black'
  }

  get goal(): 'win' | 'draw' {
    return (getConfig('goal') as 'win' | 'draw')
  }

  get instructions(): string {
    if (this.goal === 'win') {
      return this.toMove + ' to play and win'
    } else if (this.goal === 'draw') {
      return this.toMove + ' to play and draw'
    }
    return this.toMove + ' to move'
  }

  private showInstructions() {
    this.el.textContent = this.instructions
    setTimeout(() => this.el.classList.remove(`invisible`), 700)
  }

  private gameOverMan(result: '1-0' | '0-1' | '1/2-1/2') {
    let text: string
    if (this.goal === 'win') {
      if ((this.toMove === 'White' && result === '1-0') ||
          (this.toMove === 'Black' && result === '0-1')) {
        text = 'You win'
      } else {
        text = 'You failed :('
      }
    } else if (this.goal === 'draw' && result === '1/2-1/2') {
      text = 'Success!'
    } else {
      text = 'Game over'
    }
    this.el.textContent = text
    this.el.classList.remove(`invisible`)
  }
}
