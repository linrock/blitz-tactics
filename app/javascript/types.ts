export type FEN = string

export type UciMove = string

export type ChessMove = { // used by chess.js
  from: string
  to: string
  promotion?: string
}

interface InitialMove {
  san: string,
  uci: string,
}

// fields for all puzzles fetched from the server
export type Puzzle = {
  id: number
  fen: string
  lines: object
  initialMove: InitialMove
}
