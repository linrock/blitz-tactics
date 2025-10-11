import MiniChessboard from '@blitz/components/mini_chessboard'
import { solutionReplay } from '@blitz/utils/solution_replay'
import { GameEvent } from '@blitz/events'

export default {
  data() {
    return {
      playedPuzzles: [] as any[],
      currentPuzzle: null as any,
      currentPuzzleData: null as any,
      currentPuzzleStartTime: null as number | null,
      currentPuzzleMistakes: 0,
      solvedPuzzleIds: [] as string[],
    }
  },

  methods: {
    // Set up puzzle tracking event subscriptions
    setupPuzzleTrackingSubscriptions(gameModeName: string, trackingFn?: Function) {
      return {
        [GameEvent.PUZZLE_LOADED]: (data) => {
          this.currentPuzzle = data.puzzle
          this.currentPuzzleData = data
          this.currentPuzzleStartTime = Date.now()
          this.currentPuzzleMistakes = 0
          console.log('Puzzle loaded:', data.puzzle.id, 'Start time:', this.currentPuzzleStartTime)
        },
        [GameEvent.MOVE_FAIL]: () => {
          this.currentPuzzleMistakes++
          console.log('Mistake made on puzzle:', this.currentPuzzle?.id, 'Total mistakes:', this.currentPuzzleMistakes)
        },
        [GameEvent.PUZZLE_SOLVED]: async (puzzle) => {
          console.log('Puzzle solved:', puzzle)
          if (puzzle && puzzle.id) {
            this.solvedPuzzleIds.push(puzzle.id)
            console.log('Added puzzle ID:', puzzle.id, 'Total solved:', this.solvedPuzzleIds.length)
            
            const endTime = Date.now()
            const solveTimeMs = this.currentPuzzleStartTime ? endTime - this.currentPuzzleStartTime : 0
            const solveTimeSeconds = Math.round(solveTimeMs / 100) / 10
            
            if (this.currentPuzzle) {
              this.playedPuzzles.push({
                puzzle: this.currentPuzzle,
                puzzle_data: this.currentPuzzleData,
                solveTime: solveTimeSeconds,
                mistakes: this.currentPuzzleMistakes,
                puzzleNumber: this.playedPuzzles.length + 1,
                solved: true
              })
              console.log('Added played puzzle:', this.currentPuzzle.id, 'Solve time:', solveTimeSeconds + 's', 'Mistakes:', this.currentPuzzleMistakes, 'Total played:', this.playedPuzzles.length)
            }
            
            // Call custom tracking function if provided
            if (trackingFn) {
              try {
                await trackingFn(puzzle.id, gameModeName)
              } catch (error) {
                console.error('Failed to track solved puzzle:', error)
              }
            }
          } else {
            console.log('No puzzle ID found in puzzle:', puzzle)
          }
        },
      }
    },

    // Add current unsolved puzzle when game ends
    addUnsolvedPuzzle() {
      if (this.currentPuzzle) {
        this.playedPuzzles.push({
          puzzle: this.currentPuzzle,
          puzzle_data: this.currentPuzzleData,
          solveTime: null,
          mistakes: this.currentPuzzleMistakes,
          puzzleNumber: null,
          solved: false
        })
        console.log('Added unsolved puzzle:', this.currentPuzzle.id, 'Mistakes:', this.currentPuzzleMistakes)
      }
    },

    // Display the post-game puzzle section
    showPlayedPuzzlesSection(sectionId: string = 'played-puzzles-section') {
      const playedSection = document.getElementById(sectionId)
      const playedList = document.getElementById(`${sectionId.replace('-section', '-list')}`)
      
      if (!playedSection || !playedList) return
      
      playedList.innerHTML = ''
      
      const solvedPuzzles = this.playedPuzzles.filter(p => p.solved)
      const unsolvedPuzzles = this.playedPuzzles.filter(p => !p.solved)
      const allPuzzlesToShow = [...unsolvedPuzzles.reverse(), ...solvedPuzzles.reverse()]
      
      allPuzzlesToShow.forEach((puzzleData, index) => {
        const puzzleId = puzzleData.puzzle?.id || 'Unknown'
        const initialFen = puzzleData.puzzle?.fen
        const solveTime = puzzleData.solveTime
        const mistakes = puzzleData.mistakes || 0
        const isSolved = puzzleData.solved
        
        let puzzleNumber = null
        if (isSolved) {
          const originalSolvedIndex = solvedPuzzles.findIndex(p => p.puzzle?.id === puzzleId)
          puzzleNumber = solvedPuzzles.length - originalSolvedIndex
        }
        
        let initialMove = puzzleData.puzzle?.initialMove
        let initialMoveUci = null
        
        if (initialMove) {
          if (typeof initialMove === 'object' && initialMove.uci) {
            initialMoveUci = initialMove.uci
          } else if (typeof initialMove === 'string' && initialMove.length >= 4) {
            if (/^[a-h][1-8][a-h][1-8]/.test(initialMove)) {
              initialMoveUci = initialMove
            }
          }
        }
        
        const originalIndex = this.playedPuzzles.findIndex(p => p.puzzle?.id === puzzleId)
        const puzzleItem = document.createElement('div')
        // Use the appropriate class based on the section ID
        // For 'played-puzzles-section' use 'played-puzzle-item', for 'missed-puzzles-section' use 'missed-puzzle-item'
        const itemClass = sectionId.includes('missed') ? 'missed-puzzle-item' : 'played-puzzle-item'
        puzzleItem.className = itemClass
        
        let numberBadgeHtml = ''
        if (puzzleNumber) {
          numberBadgeHtml = `<div class="puzzle-number">${puzzleNumber}</div>`
        }
        
        let mistakeBadgeHtml = ''
        if (mistakes > 0) {
          mistakeBadgeHtml = `<div class="mistake-badge">${mistakes} mistake${mistakes > 1 ? 's' : ''}</div>`
        }
        
        let timeDisplayHtml = ''
        if (isSolved && solveTime) {
          timeDisplayHtml = `<div class="solve-time">Solved in ${solveTime}s</div>`
        } else if (!isSolved && solveTime) {
          timeDisplayHtml = `<div class="spent-time">Spent ${solveTime}s</div>`
        }
        
        puzzleItem.innerHTML = `
          ${numberBadgeHtml}
          ${mistakeBadgeHtml}
          <div class="puzzle-miniboard">
            <a href="/puzzles/${puzzleId}" class="miniboard-link">
              <div class="mini-chessboard" 
                   data-fen="${initialFen}" 
                   data-initial-move="${initialMoveUci || ''}" 
                   data-flip="${initialFen && initialFen.includes(' w ')}"
                   data-puzzle-id="${puzzleId}">
              </div>
            </a>
          </div>
          <div class="puzzle-info">
            <div class="puzzle-meta">
              <div class="puzzle-id">Puzzle ${puzzleId}</div>
              ${timeDisplayHtml}
            </div>
            <div class="puzzle-actions">
              <button class="view-solution-btn" data-puzzle-index="${originalIndex}">Show Solution</button>
            </div>
          </div>
        `
        playedList.appendChild(puzzleItem)
      })
      
      playedSection.style.display = 'block'
      document.body.style.overflowX = 'hidden'
      
      this.initializePlayedPuzzleMiniboards(sectionId)
      
      setTimeout(() => {
        this.addSolutionButtonHandlers(sectionId)
      }, 100)
    },

    // Initialize miniboards
    initializePlayedPuzzleMiniboards(sectionId: string) {
      const miniboards = document.querySelectorAll(`#${sectionId} .mini-chessboard:not([data-initialized])`)
      miniboards.forEach((el) => {
        const htmlEl = el as HTMLElement
        const { fen, initialMove, flip } = htmlEl.dataset
        if (fen) {
          htmlEl.setAttribute('data-initialized', 'true')
          
          let validInitialMove = initialMove
          if (initialMove && initialMove !== '') {
            if (!/^[a-h][1-8][a-h][1-8]/.test(initialMove)) {
              validInitialMove = undefined
            }
          }
          
          new MiniChessboard({
            el: htmlEl,
            fen,
            initialMove: validInitialMove,
            flip: flip === 'true'
          })
        }
      })
    },

    // Add solution button handlers
    addSolutionButtonHandlers(sectionId: string) {
      const solutionButtons = document.querySelectorAll(`#${sectionId} .view-solution-btn`)
      solutionButtons.forEach((button) => {
        const buttonEl = button as HTMLButtonElement
        buttonEl.addEventListener('click', (e) => {
          e.preventDefault()
          
          if (buttonEl.disabled) {
            return
          }
          
          const puzzleIndex = parseInt(buttonEl.dataset.puzzleIndex || '0')
          const puzzleData = this.playedPuzzles[puzzleIndex]
          if (puzzleData) {
            this.showSolutionWithButtonState(puzzleData, buttonEl, sectionId)
          }
        })
      })
    },

    // Show solution with button state management
    showSolutionWithButtonState(puzzleData, buttonEl, sectionId: string) {
      const originalText = buttonEl.textContent
      
      buttonEl.textContent = 'Showing solution...'
      buttonEl.style.opacity = '0.5'
      buttonEl.disabled = true
      
      const puzzleId = puzzleData.puzzle?.id
      if (puzzleId) {
        const miniboard = document.querySelector(`#${sectionId} .mini-chessboard[data-puzzle-id="${puzzleId}"]`)
        if (miniboard) {
          const solutionLines = puzzleData.puzzle?.lines
          if (solutionLines) {
            solutionReplay.replaySolutionOnMiniboardWithCallback(miniboard as HTMLElement, solutionLines, () => {
              buttonEl.textContent = originalText || 'Show solution'
              buttonEl.style.opacity = '1'
              buttonEl.disabled = false
            })
          } else {
            console.log('No solution lines found for puzzle:', puzzleId)
            buttonEl.textContent = originalText || 'Show solution'
            buttonEl.style.opacity = '1'
            buttonEl.disabled = false
          }
        } else {
          console.log('Miniboard not found for puzzle:', puzzleId)
          buttonEl.textContent = originalText || 'Show solution'
          buttonEl.style.opacity = '1'
          buttonEl.disabled = false
        }
      }
    },
  }
}

