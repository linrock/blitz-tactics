import { subscribe, dispatch } from '@blitz/events'
import { InitialMove, Puzzle, UciMove } from '@blitz/types'
import { uciToMove, moveToUci } from '@blitz/utils'
import Puzzles from '../puzzle_player/puzzles'
import StockfishEngine from '../../workers/stockfish_engine'
import { Chess } from 'chess.js'

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
  private isMoveComboChallenge = false
  private isCheckmateChallenge = false
  private comboCount = 0
  private comboTarget = 0
  private comboDropTime = 7
  private lastPuzzleId: string | null = null
  private engine: StockfishEngine | null = null
  private currentFen: string = ''

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
        this.isMoveComboChallenge = levelInfo.challenge === 'move_combo'
        this.isCheckmateChallenge = levelInfo.challenge === 'checkmate'
        this.puzzlesSolvedInRow = 0
        this.comboCount = 0
        this.comboTarget = levelInfo.combo_target || 30
        this.comboDropTime = levelInfo.combo_drop_time || null
        
        // Initialize engine for checkmate challenges
        if (this.isCheckmateChallenge) {
          this.engine = new StockfishEngine()
          // Set initial FEN for checkmate challenges
          this.currentFen = levelInfo.position_fen || 'rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1'
          console.log('Adventure: Initial FEN set for checkmate challenge:', this.currentFen)
          // Set the correct instructions based on color to move
          this.setCheckmateInstructions()
        }
        
        console.log('Adventure: Level loaded', {
          challenge: levelInfo.challenge,
          requiredPuzzles: this.requiredPuzzles,
          isWithoutMistakesChallenge: this.isWithoutMistakesChallenge,
          isSpeedChallenge: this.isSpeedChallenge,
          isMoveComboChallenge: this.isMoveComboChallenge,
          isCheckmateChallenge: this.isCheckmateChallenge,
          comboTarget: this.comboTarget,
          comboDropTime: this.comboDropTime,
          position_fen: levelInfo.position_fen
        })
      },
      'puzzles:fetched': puzzles => {
        if (this.isCheckmateChallenge) {
          // For checkmate challenges, we don't use puzzles - we use position trainer mode
          console.log('Adventure: Checkmate challenge detected, skipping puzzle loading')
          return
        }
        
        this.puzzles = new Puzzles()
        this.addPuzzles(puzzles)
        this.firstPuzzle()
      },
      'puzzles:next': () => {
        this.i++
        
        // For without_mistakes and move_combo challenges, cycle through puzzles indefinitely
        if (this.isWithoutMistakesChallenge || this.isMoveComboChallenge) {
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
      'move:success': () => {
        if (this.isMoveComboChallenge) {
          this.comboCount++
          console.log(`Adventure: Move combo incremented: ${this.comboCount}/${this.comboTarget}`)
          
          if (this.comboCount >= this.comboTarget) {
            console.log('Adventure: Move combo challenge completed!')
            dispatch('puzzles:complete')
            return
          }
          
          // Update the combo display
          dispatch('adventure:combo:update', { comboCount: this.comboCount, comboTarget: this.comboTarget })
          
          // Only restart timer if combo_drop_time is configured
          if (this.comboDropTime !== null) {
            dispatch('adventure:combo:timer:restart', { dropTime: this.comboDropTime })
          }
        }
      },
      'move:fail': move => {
        if (this.isWithoutMistakesChallenge) {
          console.log('Adventure: Mistake made in without_mistakes challenge, resetting counter')
          this.puzzlesSolvedInRow = 0
          dispatch('adventure:counter:reset', { puzzlesSolvedInRow: this.puzzlesSolvedInRow, requiredPuzzles: this.requiredPuzzles })
        }
        if (this.isMoveComboChallenge) {
          console.log('Adventure: Mistake made in move_combo challenge, resetting combo')
          this.comboCount = 0
          dispatch('adventure:combo:reset', { comboCount: this.comboCount, comboTarget: this.comboTarget })
        }
      },
        'timer:stopped': () => {
          if (this.isSpeedChallenge) {
            console.log('Adventure: Timer expired in speed challenge - level failed')
            // Do NOT dispatch puzzles:complete when timer runs out
            // The level should be marked as failed, not completed
          }
          if (this.isMoveComboChallenge && this.comboDropTime !== null) {
            console.log('Adventure: Combo timer expired in move_combo challenge')
            this.comboCount = 0
            dispatch('adventure:combo:reset', { comboCount: this.comboCount, comboTarget: this.comboTarget })
          }
        },
        'game:won': () => {
          if (this.isCheckmateChallenge) {
            console.log('Adventure: Checkmate challenge completed!')
            console.log('Adventure: Dispatching puzzles:complete')
            dispatch('puzzles:complete')
          }
        },
        'game:lost': () => {
          if (this.isCheckmateChallenge) {
            console.log('Adventure: Checkmate challenge failed')
            // Could add retry logic here if needed
          }
        },
        'fen:set': (fen) => {
          if (this.isCheckmateChallenge) {
            console.log('Adventure: FEN updated:', fen)
            this.currentFen = fen
          }
        },
        'move:make': (move, options = {}) => {
          if (this.isCheckmateChallenge && this.engine) {
            console.log('Adventure: Move made in checkmate challenge:', move, 'opponent:', options.opponent)
            
            // Only process player moves, not computer moves (to avoid infinite loops)
            if (!options.opponent) {
              console.log('Adventure: Player move successful, checking game state...')
              // Check if game is over after player move
              setTimeout(() => {
                this.checkGameOver()
                // If game is not over, get computer move
                setTimeout(() => {
                  this.getComputerMove()
                }, 50)
              }, 100)
            } else {
              console.log('Adventure: Computer move received, checking game state...')
              // Check if game is over after computer move
              setTimeout(() => {
                this.checkGameOver()
              }, 100)
            }
          }
        },
    })
  }



  private updateCurrentFen() {
    console.log('Adventure: updateCurrentFen called')
    // Get the current FEN from the chessground board
    const chessgroundElement = document.querySelector('.chessground-board')
    console.log('Adventure: chessgroundElement found:', !!chessgroundElement)
    if (!chessgroundElement || !(chessgroundElement as any).cg) {
      console.error('Adventure: Could not find chessground board to update FEN')
      return
    }
    
    const cg = (chessgroundElement as any).cg
    const newFen = cg.state.fen
    console.log('Adventure: New FEN from chessground:', newFen)
    console.log('Adventure: Current stored FEN:', this.currentFen)
    if (newFen !== this.currentFen) {
      console.log('Adventure: FEN updated from', this.currentFen, 'to', newFen)
      this.currentFen = newFen
    } else {
      console.log('Adventure: FEN unchanged')
    }
  }

  private getComputerMove() {
    if (!this.engine) {
      console.error('Adventure: Engine not initialized')
      return
    }
    
    // Get the current FEN from the global chessground board
    if (!(window as any).adventureChessgroundBoard) {
      console.error('Adventure: Chessground board not found')
      return
    }
    
    const currentFen = (window as any).adventureChessgroundBoard.getFen()
    console.log('Adventure: Getting computer move for FEN:', currentFen)
    
    this.engine.analyze(currentFen, { depth: 15, multipv: 1 }).then((analysis) => {
      const evaluation = analysis.state.evaluation
      if (evaluation && evaluation.best) {
        const move = uciToMove(evaluation.best)
        console.log('Adventure: Computer move calculated:', move)
        console.log('Adventure: UCI move from Stockfish:', evaluation.best)
        // Dispatch the move to update the board
        dispatch('move:make', move, { opponent: true })
      } else {
        console.error('Adventure: No computer move found')
      }
    }).catch((error) => {
      console.error('Adventure: Error getting computer move:', error)
    })
  }

  private checkGameOver() {
    console.log('Adventure: checkGameOver called')
    // Get the current FEN from the global chessground board
    if (!(window as any).adventureChessgroundBoard) {
      console.error('Adventure: Chessground board not found for game over check')
      return
    }
    
    const currentFen = (window as any).adventureChessgroundBoard.getFen()
    console.log('Adventure: Checking game over for FEN:', currentFen)
    
    // Create a temporary chess instance to check game state
    const tempChess = new Chess(currentFen)
    console.log('Adventure: Game over?', tempChess.game_over())
    console.log('Adventure: In checkmate?', tempChess.in_checkmate())
    console.log('Adventure: In stalemate?', tempChess.in_stalemate())
    console.log('Adventure: In draw?', tempChess.in_draw())
    console.log('Adventure: Turn:', tempChess.turn())
    
    if (tempChess.game_over()) {
      if (tempChess.in_checkmate()) {
        console.log('Adventure: Checkmate achieved!')
        dispatch('game:won')
      } else if (tempChess.in_stalemate()) {
        console.log('Adventure: Stalemate!')
        dispatch('game:stalemate')
      } else if (tempChess.in_draw()) {
        console.log('Adventure: Draw!')
        dispatch('game:draw')
      } else {
        console.log('Adventure: Game over but not checkmate/stalemate/draw')
        dispatch('game:lost')
      }
    } else {
      console.log('Adventure: Game not over, continuing...')
    }
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
    
    // Handle checkmate challenges differently - they don't use boardState
    if (this.isCheckmateChallenge) {
      console.log('Adventure: Checkmate challenge - accepting move')
      dispatch('move:success')
      dispatch('move:make', move)
      return
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
    if ((!this.isWithoutMistakesChallenge && !this.isMoveComboChallenge) || this.puzzles.count() === 0) {
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

  private setCheckmateInstructions() {
    if (!this.currentFen) return
    
    // Determine color to move from FEN
    const toMove = this.currentFen.indexOf(' w ') > 0 ? 'White' : 'Black'
    const instructionText = `${toMove} to move`
    
    console.log('Adventure: Setting checkmate instructions:', instructionText)
    dispatch('instructions:set', instructionText)
  }
}
