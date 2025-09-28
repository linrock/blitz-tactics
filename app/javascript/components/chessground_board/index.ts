import { Chess, ChessInstance, Move, Square } from 'chess.js'
import { Chessground } from 'chessground'
import { Api } from 'chessground/api'
import { Config } from 'chessground/config'
import { Color, Dests, FEN, Key } from 'chessground/types'
import { createApp } from 'vue'

import PiecePromoModal from '../piece_promo_modal/index.vue'
import { dispatch, subscribe } from '@blitz/events'

import './chessground.sass'
import './theme.sass'

interface MoveOptions {
  opponent?: boolean
}

const SQUARES: Square[] = [
  'a8', 'b8', 'c8', 'd8', 'e8', 'f8', 'g8', 'h8',
  'a7', 'b7', 'c7', 'd7', 'e7', 'f7', 'g7', 'h7',
  'a6', 'b6', 'c6', 'd6', 'e6', 'f6', 'g6', 'h6',
  'a5', 'b5', 'c5', 'd5', 'e5', 'f5', 'g5', 'h5',
  'a4', 'b4', 'c4', 'd4', 'e4', 'f4', 'g4', 'h4',
  'a3', 'b3', 'c3', 'd3', 'e3', 'f3', 'g3', 'h3',
  'a2', 'b2', 'c2', 'd2', 'e2', 'f2', 'g2', 'h2',
  'a1', 'b1', 'c1', 'd1', 'e1', 'f1', 'g1', 'h1'
]

const getDests = (chess: ChessInstance): Dests | null => {
  const dests: Partial<Record<Square, Square[]>> = {};
  SQUARES.forEach(square => {
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
          console.log(`Chessground: Attempting move from ${from} to ${to}`)
          console.log(`Chessground: Current FEN: ${this.cjs.fen()}`)
          console.log(`Chessground: Piece on ${from}:`, this.cjs.get(from as Square))
          
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
            console.log(`Chessground: Move result:`, moveObj)
            dispatch('move:try', moveObj)
          }
        },
        
        // handle square selection
        select: (key: Key | undefined) => {
          console.log('Square selected:', key)
          // Update highlights when selection changes
          setTimeout(() => this.createHighlightOverlays(), 10)
        }
      },
    }
    if (options.orientation) {
      cgOptions.orientation = options.orientation
    } else if (options.fen) {
      cgOptions.orientation = options.fen?.includes(' w ') ? 'black' : 'white' as Color
    }
    this.chessground = Chessground(document.querySelector(selector), cgOptions);
    
    // Create 64 individual squares after a short delay to ensure chessground is fully initialized
    setTimeout(() => {
      this.createChessSquares()
      // Also create highlights after a longer delay to ensure chessground is fully ready
      setTimeout(() => {
        this.createHighlightOverlays()
      }, 200)
    }, 100)


    createApp(PiecePromoModal).mount('.piece-promotion-modal-mount')

    subscribe({
      'board:flipped': shouldBeFlipped => {
        this.chessground.set({ orientation: shouldBeFlipped ? 'black' : 'white' })
        // Recreate squares when board orientation changes
        this.createChessSquares()
      },

      'board:update': () => {
        // Update highlights when board state changes
        this.createHighlightOverlays()
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
        // Update highlights after FEN change
        setTimeout(() => this.createHighlightOverlays(), 10)
      },

      'move:fail': () => this.resetToBeforePlayerMove(),
      'move:almost': () => this.resetToBeforePlayerMove(),

      'move:make': (move: Move, options: MoveOptions = {}) => {
        console.log(`Chessground: handling move:make ${JSON.stringify(move)} from ${this.cjs.fen()}`)
        console.log(`${options.opponent ? 'opponent' : 'player'} just moved`);
        const moveObj = this.cjs.move(move)
        if (!moveObj) {
          console.error(`Chessground: Move failed - No moveObj after move:make. FEN: ${this.cjs.fen()}, move: ${JSON.stringify(move)}`)
          throw new Error(
            `No moveObj after move:make. FEN: ${this.cjs.fen()}, move: ${JSON.stringify(move)}`
          )
        }
        console.log(`Chessground: Move successful:`, moveObj)
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
        // Update highlights after move
        setTimeout(() => this.createHighlightOverlays(), 10)
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
    // Update highlights after reset
    setTimeout(() => this.createHighlightOverlays(), 10)
  }

  private createChessSquares(): void {
    // Find the chessground wrapper
    const cgWrap = document.querySelector('.cg-wrap')
    if (!cgWrap) {
      return
    }

    // Check if squares already exist (from HTML template)
    let squaresContainer = cgWrap.querySelector('.chess-squares-container') as HTMLElement
    if (!squaresContainer) {
      // Create a background container for our squares
      squaresContainer = document.createElement('div')
      squaresContainer.className = 'chess-squares-container'
      cgWrap.insertBefore(squaresContainer, cgWrap.firstChild)

      // Clear any existing squares and highlights
      const existingSquares = squaresContainer.querySelectorAll('.chess-square, .chess-highlight')
      existingSquares.forEach(square => square.remove())

      // Create 64 squares
      for (let i = 0; i < 64; i++) {
        const square = document.createElement('div')
        square.className = 'chess-square'
        
        // Calculate position (0-63, where 0 is a8, 63 is h1)
        const file = i % 8  // 0-7 (a-h)
        const rank = Math.floor(i / 8)  // 0-7 (8-1)
        
        // Position the square
        square.style.left = `${file * 12.5}%`
        square.style.top = `${rank * 12.5}%`
        
        // Determine if square is light or dark
        // a1 (file=0, rank=7) should be dark, so we use (file + rank) % 2 === 1
        const isDark = (file + rank) % 2 === 1
        square.classList.add(isDark ? 'dark' : 'light')
        
        squaresContainer.appendChild(square)
      }
    }


    // Create highlight overlays for any currently highlighted squares
    this.createHighlightOverlays()
  }

  private createHighlightOverlays(): void {
    const cgWrap = document.querySelector('.cg-wrap')
    if (!cgWrap) return

    const squaresContainer = cgWrap.querySelector('.chess-squares-container') as HTMLElement
    if (!squaresContainer) return

    // Clear all existing highlight classes from squares
    const squares = squaresContainer.querySelectorAll('.chess-square')
    squares.forEach(square => {
      square.classList.remove('move-dest', 'selected', 'check', 'last-move-from', 'last-move-to', 'premove-dest', 'current-premove')
    })

    // Get chessground state to determine highlights
    const state = this.chessground.state
    console.log('Creating highlights for state:', state)
    
    // Add move destination highlights
    if (state.movable && state.movable.dests) {
      console.log('Move destinations:', state.movable.dests)
      Object.entries(state.movable.dests).forEach(([square, dests]) => {
        if (dests && dests.length > 0) {
          dests.forEach(dest => {
            console.log(`Adding move-dest highlight for ${dest}`)
            this.addHighlightToSquare(dest, 'move-dest', squaresContainer)
          })
        }
      })
    }

    // Add selected square highlight
    if (state.selected) {
      console.log(`Adding selected highlight for ${state.selected}`)
      this.addHighlightToSquare(state.selected, 'selected', squaresContainer)
    } else {
      console.log('No selected square')
    }

    // Add last move highlights
    if (state.lastMove && state.lastMove.length === 2) {
      console.log(`Adding last-move highlights for ${state.lastMove[0]} and ${state.lastMove[1]}`)
      this.addHighlightToSquare(state.lastMove[0], 'last-move-from', squaresContainer)
      this.addHighlightToSquare(state.lastMove[1], 'last-move-to', squaresContainer)
    }

    // Add check highlight (if king is in check)
    if (state.check) {
      console.log(`Adding check highlight for ${state.check}`)
      this.addHighlightToSquare(state.check, 'check', squaresContainer)
    }
  }

  private addHighlightToSquare(square: string, highlightType: string, container: HTMLElement): void {
    // Convert square name to file/rank coordinates
    // Chess notation: a1 is bottom-left, h8 is top-right
    // Our div system: (0,0) is top-left (a8), (7,7) is bottom-right (h1)
    const file = square.charCodeAt(0) - 97 // 'a' = 0, 'b' = 1, etc.
    const rank = 8 - parseInt(square[1]) // '1' = 7, '2' = 6, etc. (flip the rank)

    // Account for board orientation
    const orientation = this.chessground.state.orientation
    let squareIndex: number
    
    if (orientation === 'white') {
      // White orientation: a8 is top-left (0,0), h1 is bottom-right (7,7)
      squareIndex = rank * 8 + file
    } else {
      // Black orientation: h1 is top-left (0,0), a8 is bottom-right (7,7)
      // Flip both file and rank
      const flippedFile = 7 - file
      const flippedRank = 7 - rank
      squareIndex = flippedRank * 8 + flippedFile
    }

    console.log(`Adding ${highlightType} to ${square}: file=${file}, rank=${rank}, orientation=${orientation}, squareIndex=${squareIndex}`)

    // Find the corresponding square div
    const squares = container.querySelectorAll('.chess-square')
    if (squares[squareIndex]) {
      squares[squareIndex].classList.add(highlightType)
      console.log(`Successfully added ${highlightType} class to square ${squareIndex}`)
    } else {
      console.log(`Square ${squareIndex} not found for ${square}`)
    }
  }
}
