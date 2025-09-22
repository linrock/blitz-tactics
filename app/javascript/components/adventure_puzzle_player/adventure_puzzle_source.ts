import { subscribe, dispatch } from '@blitz/events'
import { InitialMove, Puzzle, UciMove } from '@blitz/types'
import { uciToMove, moveToUci } from '@blitz/utils'
import Puzzles from '../puzzle_player/puzzles'

// Adventure-specific puzzle source that works with adventure data
export default class AdventurePuzzleSource {
  private i = 0
  private puzzles = new Puzzles()
  private started = false
  private firstMoveT: number | undefined
  private current: any = {}
  private mode: string = 'adventure'

  constructor() {
    this.initializePuzzleSource()
    this.setupEventListeners()
  }

  private initializePuzzleSource() {
    // Puzzle source initialization - puzzles will be loaded via events
  }

  private setupEventListeners() {
    subscribe({
      'puzzles:fetched': puzzles => {
        this.puzzles = new Puzzles()
        this.addPuzzles(puzzles)
        this.firstPuzzle()
      },
      'puzzles:next': () => {
        this.i++
        if (this.i >= this.puzzles.count()) {
          dispatch('puzzles:complete')
        } else {
          const n = this.puzzles.count()
          dispatch(`puzzles:status`, {
            i: this.i,
            lastPuzzleId: this.puzzles.lastPuzzle().id,
            n,
          })
          this.nextPuzzle()
        }
      },
      'puzzle:get_hint': () => {
        const hints: string[] = Object.keys(this.current.boardState).filter((move: UciMove) => {
          return this.current.boardState[move] !== 'retry'
        })
        dispatch('puzzle:hint', hints[~~(Math.random() * hints.length)])
      },
      'move:try': move => {
        console.log('Adventure: Received move:try event', move)
        console.log('Adventure: About to call tryUserMove')
        this.tryUserMove(move)
        console.log('Adventure: tryUserMove completed')
      },
    })
  }

  private addPuzzles(puzzles) {
    this.puzzles.addPuzzles(puzzles)
  }

  private firstPuzzle() {
    this.i = 0
    this.nextPuzzle()
  }

  private nextPuzzle() {
    if (this.puzzles.count() === 0) {
      console.log('AdventurePuzzleSource: no puzzles available')
      return
    }

    const puzzle = this.puzzles.puzzleAt(this.i)
    this.current = {
      boardState: Object.assign({}, puzzle.lines),
      puzzle,
    }

    dispatch('puzzle:loaded', puzzle)
    dispatch('board:flipped', !!puzzle.fen.match(/ w /))
    dispatch('fen:set', puzzle.fen)

    // Set up the first move delay
    this.firstMoveT = window.setTimeout(() => {
      this.playFirstMove()
    }, 300)
  }

  private playFirstMove() {
    if (!this.current.puzzle) return

    const initialMove: InitialMove = this.current.puzzle.initialMove
    if (initialMove) {
      const move = this.getInitialMoveSan(initialMove)
      dispatch('move:make', move, { opponent: true })
      dispatch('move:sound', move)
    }
  }

  private getInitialMoveSan(move: InitialMove): string | any {
    return move.uci ? uciToMove(move.uci) : uciToMove(move as any)
  }

  private tryUserMove(move: any) {
    console.log('Adventure: tryUserMove called, started:', this.started)
    if (!this.started) {
      this.started = true
      console.log('Adventure: Dispatching puzzles:start')
      dispatch('puzzles:start')
    } else {
      console.log('Adventure: Already started, not dispatching puzzles:start')
    }
    
    if (!this.current.boardState) return

    const attempt = this.current.boardState[moveToUci(move)]
    if (attempt === 'win') {
      dispatch('move:success')
      dispatch('move:make', move)
      this.handlePuzzleSolved()
      return
    } else if (attempt === 'retry') {
      dispatch('move:almost', move)
      return
    }
    const response = attempt ? Object.keys(attempt)[0] : null
    if (!response) {
      dispatch('move:fail', move)
      return
    }
    dispatch('move:make', move)
    dispatch('move:success')
    if (attempt[response] === 'win') {
      this.handlePuzzleSolved()
    } else {
      dispatch('move:sound', move)
      const responseMove = uciToMove(response)
      setTimeout(() => {
        dispatch('move:make', responseMove, { opponent: true })
        this.current.boardState = attempt[response]
      }, 0)
    }
  }

  private handlePuzzleSolved() {
    console.log(`Adventure puzzle ${this.i + 1} solved!`)
    dispatch('puzzle:solved', this.current.puzzle)
    dispatch('puzzles:next')
  }
}
