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
      'puzzles:fetched': puzzles => {
        this.puzzles = new Puzzles()
        this.addPuzzles(puzzles)
        this.firstPuzzle()
      },
      'puzzles:next': () => {
        const n = this.puzzles.count()
        dispatch(`puzzles:status`, {
          i: this.i,
          lastPuzzleId: this.puzzles.lastPuzzle().id,
          n,
        })
        this.nextPuzzle()
      },
      'puzzle:get_hint': () => {
        const hints: string[] = Object.keys(this.current.boardState).filter((move: UciMove) => {
          return this.current.boardState[move] !== 'retry'
        })
        dispatch('puzzle:hint', hints[~~(Math.random() * hints.length)])
      },
      'move:try': move => this.tryUserMove(move),
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
      dispatch(`puzzles:complete`)
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
    dispatch(`puzzle:loaded`, this.current)
    dispatch(`board:flipped`, !!puzzle.fen.match(/ w /))
    dispatch(`fen:set`, puzzle.fen)
    this.firstMoveT = window.setTimeout(() => {
      const move = this.getInitialMoveSan(puzzle.initialMove)
      dispatch(`move:make`, move, { opponent: true })
      dispatch(`move:sound`, move)
      this.firstMoveT = undefined
    }, 300)
  }

  private tryUserMove(move: any) {
    if (!this.started) {
      this.started = true
      dispatch(`puzzles:start`)
    }
    const attempt = this.current.boardState[moveToUci(move)]
    if (attempt === `win`) {
      dispatch(`move:success`)
      dispatch(`move:make`, move)
      this.puzzleSolved()
      return
    } else if (attempt === `retry`) {
      dispatch(`move:almost`, move)
      return
    }
    const response = attempt ? Object.keys(attempt)[0] : null
    if (!response) {
      dispatch(`move:fail`, move)
      return
    }
    dispatch(`move:make`, move)
    dispatch(`move:success`)
    if (attempt[response] === `win`) {
      this.puzzleSolved()
    } else {
      dispatch(`move:sound`, move)
      const responseMove = uciToMove(response)
      setTimeout(() => {
        dispatch(`move:make`, responseMove, { opponent: true })
        this.current.boardState = attempt[response]
      }, 0)
    }
  }

  private puzzleSolved() {
    dispatch(`puzzle:solved`, this.current.puzzle)
    dispatch(`puzzles:next`)
  }
}
