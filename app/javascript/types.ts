export type FEN = string

export type UciMove = string

export type ChessMove = { // used by chess.js
  from: string
  to: string
  promotion?: string
}
