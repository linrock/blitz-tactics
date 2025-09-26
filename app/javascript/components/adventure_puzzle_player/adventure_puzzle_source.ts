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
  private levelInfo: any = null
  private puzzlesSolvedInRow = 0
  private requiredPuzzles = 0
  private isWithoutMistakesChallenge = false
  private isSpeedChallenge = false
  private lastPuzzleId: string | null = null

  constructor() {
    this.initializePuzzleSource()
    this.setupEventListeners()
  }

  private initializePuzzleSource() {
    // Puzzle source initialization - puzzles will be loaded via events
  }

  private setupEventListeners() {
    subscribe({
      'adventure:level:loaded': levelInfo => {
        this.levelInfo = levelInfo
        this.requiredPuzzles = levelInfo.puzzle_count || 0
        this.isWithoutMistakesChallenge = levelInfo.challenge === 'without_mistakes'
        this.isSpeedChallenge = levelInfo.challenge === 'speed'
        this.puzzlesSolvedInRow = 0
        console.log('Adventure: Level loaded', {
          challenge: levelInfo.challenge,
          requiredPuzzles: this.requiredPuzzles,
          isWithoutMistakesChallenge: this.isWithoutMistakesChallenge,
          isSpeedChallenge: this.isSpeedChallenge
        })
      },
      'puzzles:fetched': puzzles => {
        this.puzzles = new Puzzles()
        this.addPuzzles(puzzles)
        this.firstPuzzle()
      },
      'puzzles:next': () => {
        this.i++
        
        // For without_mistakes challenges, cycle through puzzles indefinitely
        if (this.isWithoutMistakesChallenge) {
          // Reset to beginning if we've gone through all puzzles
          if (this.i >= this.puzzles.count()) {
            this.shufflePuzzles()
            this.i = 0
          }
          const n = this.puzzles.count()
          dispatch(`puzzles:status`, {
            i: this.i,
            lastPuzzleId: this.puzzles.lastPuzzle().id,
            n,
          })
          this.nextPuzzle()
        } else {
          // Normal behavior for other challenge types
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
      'move:fail': move => {
        if (this.isWithoutMistakesChallenge) {
          console.log('Adventure: Mistake made in without_mistakes challenge, resetting counter')
          this.puzzlesSolvedInRow = 0
          dispatch('adventure:counter:reset', { puzzlesSolvedInRow: this.puzzlesSolvedInRow, requiredPuzzles: this.requiredPuzzles })
        }
      },
      'timer:stopped': () => {
        if (this.isSpeedChallenge) {
          console.log('Adventure: Timer expired in speed challenge')
          dispatch('puzzles:complete')
        }
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

    // Track the last puzzle ID for shuffling logic
    this.lastPuzzleId = puzzle.id

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
    
    if (this.isWithoutMistakesChallenge) {
      this.puzzlesSolvedInRow++
      console.log(`Adventure: Puzzles solved in row: ${this.puzzlesSolvedInRow}/${this.requiredPuzzles}`)
      
      if (this.puzzlesSolvedInRow >= this.requiredPuzzles) {
        console.log('Adventure: Without mistakes challenge completed!')
        dispatch('puzzles:complete')
        return
      }
      
      // Update the counter display
      dispatch('adventure:counter:update', { puzzlesSolvedInRow: this.puzzlesSolvedInRow, requiredPuzzles: this.requiredPuzzles })
    }
    
    dispatch('puzzles:next')
  }

  private shufflePuzzles() {
    if (!this.isWithoutMistakesChallenge || this.puzzles.count() === 0) {
      return
    }

    console.log('Adventure: Shuffling puzzles to prevent repetition')
    
    // Get all puzzle IDs
    const puzzleIds = []
    for (let i = 0; i < this.puzzles.count(); i++) {
      puzzleIds.push(this.puzzles.puzzleAt(i).id)
    }

    // Shuffle the array using Fisher-Yates algorithm
    for (let i = puzzleIds.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      ;[puzzleIds[i], puzzleIds[j]] = [puzzleIds[j], puzzleIds[i]]
    }

    // Ensure the first puzzle is not the same as the last puzzle from the previous iteration
    if (this.lastPuzzleId && puzzleIds[0] === this.lastPuzzleId && puzzleIds.length > 1) {
      // Swap the first puzzle with a random one from the rest
      const randomIndex = Math.floor(Math.random() * (puzzleIds.length - 1)) + 1
      ;[puzzleIds[0], puzzleIds[randomIndex]] = [puzzleIds[randomIndex], puzzleIds[0]]
    }

    // Rebuild the puzzles collection with the shuffled order
    const shuffledPuzzles = []
    for (const puzzleId of puzzleIds) {
      const puzzle = this.puzzles.puzzleAt(0) // Get any puzzle to access the collection
      // Find the puzzle with this ID and add it to shuffled array
      for (let i = 0; i < this.puzzles.count(); i++) {
        const p = this.puzzles.puzzleAt(i)
        if (p.id === puzzleId) {
          shuffledPuzzles.push(p)
          break
        }
      }
    }

    // Replace the puzzles collection
    this.puzzles = new Puzzles()
    this.puzzles.addPuzzles(shuffledPuzzles)
    
    console.log('Adventure: Puzzles shuffled, new order:', puzzleIds.slice(0, 5), '...')
  }
}
