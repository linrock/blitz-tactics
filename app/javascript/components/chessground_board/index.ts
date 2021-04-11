import { Chess, ChessInstance, Move, Square } from 'chess.js'
import { Chessground } from 'chessground'
import { Api } from 'chessground/api'
import { Config } from 'chessground/config'
import { Color, Dests, FEN, Key } from 'chessground/types'

import PiecePromoModal from '../piece_promo_modal'
import { dispatch, subscribe } from '@blitz/events'

import './chessground.sass'
import './theme.sass'

interface MoveOptions {
  opponent?: boolean
}

const getDests = (chess: ChessInstance): Dests | null => {
  const dests: Partial<Record<Square, Square[]>> = {};
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

// Options used to initialize the board
interface BoardOptions {
  fen?: FEN;
  intentOnly?: boolean;
  orientation?: Color;
  viewOnly?: boolean;
}

export default class ChessgroundBoard {
  private readonly cjs: ChessInstance
  private readonly chessground: Api
  private lastOpponentMove: any /* ChessJsMove */

  constructor(options: BoardOptions = {}, selector = '.chessground') {
    this.cjs = new Chess()
    if (options.fen && !this.cjs.load(options.fen)) {
      console.warn(`failed to load fen: ${options.fen}`)
    }
    const cgOptions: Config = {
      animation: {
        enabled: false,
        duration: 0,
      },
      highlight: {
        lastMove: true,
      },
      fen: options.fen || '0/0/0/0/0/0/0/0',
      viewOnly: options.viewOnly || false,
      movable: {
        free: false,
        intentOnly: options.intentOnly || true,
        dests: getDests(this.cjs),
        showDests: false,
      },
      draggable: {
        distance: 1,
        autoDistance: false,
        showGhost: true,
      },
      events: {
        // handle player moves
        move: (from: Key, to: Key) => {
          // TODO ideally we never update the board based on the player move right away
          // this avoids a flash of a piece being dropped on the wrong square
          const piece = this.cjs.get(from as Square)
          const { color, type } = piece
          if (type === 'p' &&
              ((color === 'w' && from[1] === '7' && to[1] === '8') ||
              (color === 'b' && from[1] === '2' && to[1] === '1'))) {
            // handle piece promotions
            const validMoves: Move[] = this.cjs.moves({ verbose: true })
            if (validMoves.find(m => m.from === from && m.to === to)) {
              dispatch(`move:promotion`, {
                fen: this.cjs.fen(),
                move: { from, to },
                lastMove: this.chessground.state.lastMove
              })
            }
          } else {
            // go through the move:try flow to decide whether to accept the move
            const cjs = new Chess(this.cjs.fen())
            const moveObj = cjs.move({ from: from as Square, to: to as Square })
            dispatch('move:try', moveObj)
          }
        }
      },
    }
    if (options.orientation) {
      cgOptions.orientation = options.orientation
    } else if (options.fen) {
      cgOptions.orientation = options.fen?.includes(' w ') ? 'black' : 'white' as Color
    }
    this.chessground = Chessground(document.querySelector(selector), cgOptions);

    new PiecePromoModal()

    subscribe({
      'board:flipped': shouldBeFlipped => {
        this.chessground.set({ orientation: shouldBeFlipped ? 'black' : 'white' })
      },

      'fen:set': (fen: FEN, lastMove?: [Square, Square]) => {
        console.log(`chessground_board - fen:set - ${fen}`)
        this.cjs.load(fen)
        const turnColor = this.cjs.turn() === 'w' ? 'white' : 'black'
        this.chessground.set({
          fen,
          lastMove: lastMove || [],
          movable: {
            color: turnColor,
            dests: getDests(this.cjs),
          },
          turnColor,
        })
      },

      'move:fail': () => this.resetToBeforePlayerMove(),
      'move:almost': () => this.resetToBeforePlayerMove(),

      'move:make': (move: Move, options: MoveOptions = {}) => {
        // console.warn(`handling move:make ${move} from ${this.cjs.fen()}`)
        // console.log(`${options.opponent ? 'opponent' : 'player'} just moved`);
        const moveObj = this.cjs.move(move)
        if (!moveObj) {
          throw new Error(
            `No moveObj after move:make. FEN: ${this.cjs.fen()}, move: ${JSON.stringify(move)}`
          )
        }
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

      'shape:draw': (square: Square) => {
        const brushes = ['green', 'red', 'blue', 'yellow']
        this.chessground.setShapes([{
          orig: square,
          brush: brushes[~~(Math.random() * brushes.length)]
        }])
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

  // Resets the board to the position before the player's last attempted move
  private resetToBeforePlayerMove() {
    // re-highlight the opponent's last move upon a move failure
    if (!this.lastOpponentMove) {
      console.error(`Missing lastOpponentMove after a move:fail`)
      return;
    }
    const turnColor = this.cjs.turn() === 'w' ? 'white' : 'black'
    const { from, to } = this.lastOpponentMove;
    // reset the board to the position before the mistake
    this.chessground.set({
      fen: this.cjs.fen(),
      lastMove: [from, to],
      movable: { dests: getDests(this.cjs) },
      turnColor,
    })
  }
}
