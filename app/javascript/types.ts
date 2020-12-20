// Represents data structures used in the JS part of the codebase
// These are reflections of the data format used to persist the puzzles

export type FEN = string

export type UciMove = string

export interface InitialMove {
  san: string,
  uci: UciMove,
}

export interface PuzzleLines {
  [uciMove: string]: PuzzleLines | 'win' | 'retry'
}

// fields for all puzzles fetched from the server
export type Puzzle = {
  id: number
  fen: FEN
  lines: PuzzleLines
  initialMove: InitialMove
}

// For bootstrapping the page with JS data and query params
export interface BlitzConfig {
  levelPath?: string
  position?: object
  loggedIn?: boolean
}