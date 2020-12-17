import { Chess, ChessInstance, Move, Square } from 'chess.js'
import { Chessground } from 'chessground'
import { Color, Dests, FEN, Key, Piece } from 'chessground/types'

import PiecePromoModal from '../piece_promo_modal'
import { dispatch, subscribe } from '@blitz/store'

import './chessground.sass'
import './theme.sass'

interface MoveOptions {
  opponent?: boolean
}

const getDests = (chess: ChessInstance): Dests | null => {
  const dests = {};
  chess.SQUARES.forEach(square => {
    const ms = chess.moves({ square, verbose: true });
    if (ms.length) dests[square] = ms.map(m => m.to);
  });
  const destsRows = Object.entries(dests)
  if (destsRows.length > 0) {
    return new Map(destsRows) as Dests;
  } else {
    return null;
  }
};

export default class ChessgroundBoard {
  private readonly cjs: ChessInstance
  private readonly chessground: any /* Chessground */
  private lastOpponentMove: any /* ChessJsMove */

  constructor(fen: FEN, selector: string = '.chessground') {
    this.cjs = new Chess()
    if (!this.cjs.load(fen)) {
      console.warn(`failed to load fen: ${fen}`)
    }
    this.chessground = Chessground(document.querySelector(selector), {
      animation: {
        enabled: false,
        duration: 0,
      },
      highlight: {
        lastMove: true,
      },
      orientation: (fen.includes(' w ') ? 'black' : 'white' as Color),
      fen,
      movable: {
        free: false,
        dests: getDests(this.cjs),
        showDests: false,
        events: {
          after: (orig, dest, metadata) => {
            console.log(`movable.events.after - ${orig} ${dest}`)
          },
        },
      },
      draggable: {
        distance: 1,
        autoDistance: false,
      },
      events: {
        // handle player moves
        move: (orig: Key, dest: Key, capturedPiece?: Piece) => {
          // reset the board to the position prior to the player's move
          // TODO ideally we never update the board based on the player move right away
          // this avoids a flash of a piece being dropped on the wrong square
          this.chessground.set({
            fen: this.cjs.fen(),
            lastMove: [],
            movable: { dests: getDests(this.cjs) },
          })
          const piece = this.cjs.get(orig as Square)
          const { color, type } = piece
          if (type === 'p' &&
              ((color === 'w' && orig[1] === '7' && dest[1] === '8') ||
              (color === 'b' && orig[1] === '2' && dest[1] === '1'))) {
            // handle piece promotions
            const validMoves: Array<Move> = this.cjs.moves({ verbose: true })
            if (validMoves.find(m => m.from === orig && m.to === dest)) {
              dispatch(`move:promotion`, {
                fen: this.cjs.fen(),
                move: { from: orig, to: dest }
              })
            }
          } else {
            // go through the move:try flow to decide whether to accept the move
            dispatch('move:try', { from: orig, to: dest })
          }
        }
      }
    });

    new PiecePromoModal()

    subscribe({
      'fen:set': (fen: FEN) => {
        console.warn(`chessground_board - got fen:set - ${fen}`)
        this.cjs.load(fen)
        const turnColor = this.cjs.turn() === 'w' ? 'white' : 'black'
        this.chessground.set({
          fen,
          lastMove: [],
          movable: {
            color: turnColor,
            dests: getDests(this.cjs)
          },
          turnColor,
        })
      },

      'move:fail': () => {
        // re-highlight the opponent's last move upon a move failure
        if (this.lastOpponentMove) {
          const turnColor = this.cjs.turn() === 'w' ? 'white' : 'black'
          const { from, to } = this.lastOpponentMove;
          this.chessground.set({
            lastMove: [from, to],
            turnColor,
          })
        }
        console.log('got move:fail')
      },

      'move:make': (move: Move, options: MoveOptions = {}) => {
        // console.warn(`handling move:make ${move} from ${this.cjs.fen()}`)
        // console.log(`${options.opponent ? 'opponent' : 'player'} just moved`);
        const moveObj = this.cjs.move(move)
        // console.log(`last move: ${moveObj.from}, ${moveObj.to}`)
        let lastMove = []
        if (options.opponent) {
          // only highlight squares after opponent moves
          lastMove = [moveObj.from, moveObj.to]
          this.lastOpponentMove = moveObj;
        }
        const turnColor = this.cjs.turn() === 'w' ? 'white' : 'black'
        this.chessground.set({
          fen: this.cjs.fen(),
          lastMove,
          movable: {
            color: turnColor,
            dests: getDests(this.cjs),
          },
          turnColor,
        })
        dispatch('fen:updated', this.cjs.fen())
      },
    })
  }

  // Prevents further player moves on the board
  public freeze() {
    this.chessground.set({ viewOnly: true })
  }

  // Enables player moves
  public unfreeze() {
    this.chessground.set({ viewOnly: false })
  }

  public setOrientation(color: 'white' | 'black') {
    this.chessground.set({ orientation: color })
  }

  public getFen(): FEN {
    return this.cjs.fen()
  }
}
