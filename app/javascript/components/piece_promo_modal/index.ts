import Backbone from 'backbone'
import Mousetrap from 'mousetrap'
import { Chess, ShortMove, Square } from 'chess.js'

import { dispatch, subscribe } from '@blitz/events'
import { FEN } from '@blitz/types'

import './style.sass'

/** When you make a pawn move that requires pawn promotion, this is what shows up */
export default class PiecePromotionModal extends Backbone.View {
  private fen: FEN
  private lastMove: [Square, Square]
  private moveIntent: ShortMove
  private readonly cjs = new Chess

  private template(color: 'w' | 'b'): string {
    return `
      <div class="piece-promotion-modal">
        <div class="prompt">
          Choose your destiny
        </div>
        <div class="pieces">
          ${['q', 'r', 'n', 'b'].map((piece) => (`
            <a class="piece" href="javascript:" data-piece="${piece}">
              <svg viewBox="0 0 45 45">
                <use xlink:href="#${color}${piece}" width="100%" height="100%"/>
              </svg>
            </a>`
          )).join('')}
        </div>
      </div>
      <div class="background"></div>
    `
  }

  // @ts-ignore
  get el(): HTMLElement {
    return document.querySelector(`.piece-promotion-modal-container`)
  }

  events(): Backbone.EventsHash {
    return {
      'click .piece' : '_selectPiece',
      'click .background' : 'cancelMove'
    }
  }

  initialize() {
    subscribe({
      'move:promotion': data => {
        this.fen = data.fen
        this.moveIntent = data.move as ShortMove
        this.lastMove = data.lastMove
        this.show()
      }
    })
  }

  private show() {
    this.el.innerHTML = this.template(this.fen.includes(' w ') ? 'w' : 'b')
    this.el.style.display = 'block'
    this.el.style.zIndex = '1000'
    Mousetrap.bind('esc', () => this.cancelMove())
  }

  private hide() {
    this.el.style.display = 'none'
    this.el.style.zIndex = '0'
    Mousetrap.unbind('esc')
  }

  private cancelMove() {
    this.hide()
    dispatch('fen:set', this.fen, this.lastMove)
  }

  private _selectPiece(e, childElement: HTMLElement) {
    const chosenPiece = childElement.dataset.piece
    const move: ShortMove = Object.assign({}, this.moveIntent, {
      promotion: chosenPiece
    })
    this.cjs.load(this.fen)
    const m = this.cjs.move(move)
    if (m) {
      dispatch('move:try', m)
    }
    this.hide()
  }
}
