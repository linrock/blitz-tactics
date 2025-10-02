import { subscribe, dispatch } from '@blitz/events'
import { InitialMove, Puzzle, UciMove } from '@blitz/types'
import { uciToMove, moveToUci } from '@blitz/utils'
import Puzzles from '../puzzle_player/puzzles'

// Quest-specific puzzle source that works with quest data
export default class QuestPuzzleSource {
  private i = 0
  private puzzles = new Puzzles()
  private started = false
  private firstMoveT: number | undefined
  private current: any = {}
  private mode: string = 'quest'

  constructor() {
    this.setupEventListeners()
  }

  private setupEventListeners() {
    subscribe({
      [GameEvent.PUZZLES_FETCHED]: puzzles => {
        this.puzzles = new Puzzles()
        this.addPuzzles(puzzles)
        this.firstPuzzle()
      },
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

  private addPuzzles(puzzles) {
    this.puzzles.addPuzzles(puzzles)
  }

  private firstPuzzle() {
    this.i = 0
    // Small delay to ensure all views have subscribed to events
    setTimeout(() => this.loadPuzzleAtIndex(this.i), 10)
  }

  private nextPuzzle() {
    this.i = this.i + 1
    if (this.i === this.puzzles.count()) {
      dispatch(GameEvent.PUZZLES_COMPLETE)
    } else {
      this.loadPuzzleAtIndex(this.i)
    }
  }

  private getInitialMoveSan(move: InitialMove): string | any {
    if (move.san) {
      return move.san
    } else {
      return move.uci ? uciToMove(move.uci) : uciToMove(move as any)
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
    }, 300)
  }

  private tryUserMove(move: any) {
    if (!this.started) {
      this.started = true
      dispatch(GameEvent.PUZZLES_START)
    }
    const attempt = this.current.boardState[moveToUci(move)]
    if (attempt === `win`) {
      dispatch(GameEvent.MOVE_SUCCESS)
      dispatch(GameEvent.MOVE_MAKE, move)
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
      }, 0)
    }
  }

  private puzzleSolved() {
    dispatch(GameEvent.PUZZLE_SOLVED, this.current.puzzle)
    dispatch(GameEvent.PUZZLES_NEXT)
  }
}
