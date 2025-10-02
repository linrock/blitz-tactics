// fetches puzzles from the server, handles player moves,
// and emits move events (move:success, move:almost, move:fail)

import { ShortMove, Move } from 'chess.js'

import { fetchPuzzles } from '@blitz/api/requests'
import { dispatch, subscribe, GameEvent } from '@blitz/events'
import { InitialMove, Puzzle, UciMove } from '@blitz/types'
import { uciToMove, moveToUci } from '@blitz/utils'
import Puzzles from './puzzles'

// source:changed
// puzzles:fetched
// puzzles:start
// puzzles:lap
// puzzle:loaded
// fen:set
// move:make
// move:almost
// move:success
// move:fail

// delay (ms) before opponent's first move is played at the start of puzzles
const FIRST_MOVE_DELAY = 300
const responseDelay = 0

export interface PuzzleState {
  boardState?: object,
  puzzle?: Puzzle,
}

export interface PuzzleSourceOptions {
  shuffle?: boolean,
  loopPuzzles?: boolean,
  mode?: string,
  source?: string,
}

export default class PuzzleSource {
  private i = 0
  private puzzles = new Puzzles()
  private started = false
  private shuffle = false
  private loopPuzzles = false
  private firstMoveT: number | undefined
  private current: PuzzleState = {}
  private mode: string

  // options - shuffle, loopPuzzles, source, mode
  constructor(options: PuzzleSourceOptions = {}) {
    this.shuffle = options.shuffle
    this.loopPuzzles = options.loopPuzzles
    this.mode = options.mode
    this.fetchPuzzles(options.source)
    subscribe({
      'source:changed': path => this.fetchPuzzles(path),
      'source:changed:add': path => this.fetchAndAddPuzzles(path),
      [GameEvent.PUZZLES_FETCHED]: puzzles => {
        this.puzzles = new Puzzles()
        this.addPuzzles(puzzles)
        this.firstPuzzle()
      },
      'puzzles:added': puzzles => this.addPuzzles(puzzles),
      [GameEvent.PUZZLES_NEXT]: () => {
        const n = this.puzzles.count()
        dispatch(GameEvent.PUZZLES_STATUS, {
          i: this.i,
          lastPuzzleId: this.puzzles.lastPuzzle().id,
          n,
        })
        this.nextPuzzle()
      },
      [GameEvent.PUZZLE_GET_HINT]: () => {
        const hints: string[] = Object.keys(this.current.boardState).filter((move: UciMove) => {
          return this.current.boardState[move] !== 'retry'
        })
        dispatch(GameEvent.PUZZLE_HINT, hints[~~(Math.random() * hints.length)])
      },
      [GameEvent.MOVE_TRY]: move => this.tryUserMove(move),
    })
  }

  private fetchPuzzles(source: string) {
    fetchPuzzles(source).then(data => {
      dispatch(GameEvent.PUZZLES_FETCHED, data.puzzles)
      dispatch(GameEvent.CONFIG_INIT, data)
    })
  }

  private fetchAndAddPuzzles(source: string) {
    fetchPuzzles(source).then(data => dispatch(`puzzles:added`, data.puzzles))
  }

  private addPuzzles(puzzles) {
    this.puzzles.addPuzzles(puzzles)
  }

  private firstPuzzle() {
    this.i = 0
    this.loadPuzzleAtIndex(this.i)
  }

  private nextPuzzle() {
    this.i = this.i + 1
    if (this.i === this.puzzles.count()) {
      if (this.shuffle) {
        this.puzzles.shuffle()
      }
      if (this.loopPuzzles) {
        this.i = 0
        dispatch(GameEvent.PUZZLES_LAP)
        this.loadPuzzleAtIndex(this.i)
      } else {
        dispatch(GameEvent.PUZZLES_COMPLETE)
      }
    } else {
      this.loadPuzzleAtIndex(this.i)
    }
  }

  // TODO should make this one type of move
  private getInitialMoveSan(move: InitialMove): string | ShortMove {
    if (move.san) {
      return move.san
    } else {
      return move.uci ? uciToMove(move.uci) : uciToMove(move as any) // TODO
    }
  }

  private loadPuzzleAtIndex(i: number) {
    const puzzle = this.puzzles.puzzleAt(i)
    this.current = {
      boardState: Object.assign({}, puzzle.lines),
      puzzle,
    }
    clearTimeout(this.firstMoveT)
    dispatch(GameEvent.PUZZLE_LOADED, this.current)
    dispatch(GameEvent.BOARD_FLIPPED, !!puzzle.fen.match(/ w /))
    dispatch(GameEvent.FEN_SET, puzzle.fen)
    this.firstMoveT = window.setTimeout(() => {
      const move = this.getInitialMoveSan(puzzle.initialMove)
      dispatch(GameEvent.MOVE_MAKE, move, { opponent: true })
      dispatch(GameEvent.MOVE_SOUND, move)
      this.firstMoveT = undefined
    }, FIRST_MOVE_DELAY)
  }

  private tryUserMove(move: Move) {
    if (!this.started) {
      this.started = true
      dispatch(GameEvent.PUZZLES_START)
    }
    const attempt = this.current.boardState[moveToUci(move)]
    if (attempt === `win`) {
      dispatch(GameEvent.MOVE_SUCCESS)
      if (this.mode === `rated`) {
        dispatch(GameEvent.MOVE_MAKE, move)
      } else if (this.i === this.puzzles.count() - 1) {
        // TODO look into whether this check is needed
        dispatch(GameEvent.MOVE_MAKE, move)
      }
      this.puzzleSolved()
      return
    } else if (attempt === `retry`) {
      dispatch(GameEvent.MOVE_ALMOST, move)
      return
    }
    const response = attempt ? Object.keys(attempt)[0] : null
    if (!response) {
      dispatch(GameEvent.MOVE_FAIL, move)
      return
    }
    dispatch(GameEvent.MOVE_MAKE, move)
    dispatch(GameEvent.MOVE_SUCCESS)
    if (attempt[response] === `win`) {
      this.puzzleSolved()
    } else {
      dispatch(GameEvent.MOVE_SOUND, move)
      const responseMove = uciToMove(response)
      setTimeout(() => {
        dispatch(GameEvent.MOVE_MAKE, responseMove, { opponent: true })
        this.current.boardState = attempt[response]
      }, responseDelay)
    }
  }

  private puzzleSolved() {
    dispatch(GameEvent.PUZZLE_SOLVED, this.current.puzzle)
    dispatch(GameEvent.PUZZLES_NEXT)
  }
}
