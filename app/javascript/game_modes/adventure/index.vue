<template>
  <div class="adventure-mode" v-if="levelInfo">
    <div v-if="!setCompleted" class="adventure-header">
      <h2>Level {{ levelInfo.level_number }}-{{ levelInfo.set_index }}: {{ levelInfo.level_description }}</h2>
    </div>
    
    <!-- Show completion info in place of progress when completed -->
    <div v-if="setCompleted" class="adventure-progress">
      <div class="adventure-completion-info">
        <div class="completion-message">Level {{ levelInfo.level_number }}-{{ levelInfo.set_index }} completed!</div>
        <div v-if="completionTime" class="completion-time">Time: {{ formatTime(completionTime) }}</div>
        <div v-if="bestTime" class="best-time">Best Time: {{ formatTime(bestTime) }}</div>
        <div v-else-if="completionTime" class="best-time">Best Time: {{ formatTime(completionTime) }}</div>
        <button class="completion-button" @click="returnToHomepage">Continue</button>
      </div>
    </div>
    
    <!-- Show normal progress when not completed -->
    <div v-else class="adventure-progress">
      <div v-if="isSpeedChallenge && !timerExpired" class="timer-section">
        <timer :time-limit="levelInfo.time_limit"></timer>
      </div>
      <div v-if="isMoveComboChallenge && comboDropTime !== null" class="combo-timer-section">
        <combo-timer :drop-time="comboDropTime"></combo-timer>
      </div>
      
      <!-- Timer expired message -->
      <div v-if="timerExpired" class="timer-expired-section">
        <div class="timer-expired-message">Time is up!</div>
        <button class="retry-button" @click="retryLevel">Retry</button>
      </div>
      
      <!-- Game lost message (stalemate/draw) -->
      <div v-if="gameLost" class="game-lost-section">
        <div class="game-lost-message">{{ gameLostMessage }}</div>
        <button class="retry-button" @click="retryLevel">Retry</button>
      </div>
      
      <!-- Progress text (hidden when timer expires or game lost) -->
      <div v-if="!timerExpired && !gameLost" class="progress-text">
        <span v-if="!hasStarted" class="solve-text">
          <span v-if="isWithoutMistakesChallenge">
            Solve <span class="total">{{ requiredPuzzles }}</span> puzzles without mistakes
          </span>
          <span v-else-if="isSpeedChallenge">
            Solve <span class="total">{{ requiredPuzzles }}</span> puzzles in {{ levelInfo.time_limit || 60 }} seconds
          </span>
          <span v-else-if="isMoveComboChallenge">
            Reach move combo <span class="total">{{ comboTarget }}</span>
          </span>
          <span v-else-if="isCheckmateChallenge">
            Win by checkmate
          </span>
          <span v-else>
            Solve <span class="total">{{ levelInfo.puzzle_count }}</span> puzzles
          </span>
        </span>
        <span v-else class="solved-text">
          <span v-if="isWithoutMistakesChallenge">
            <span class="current">{{ puzzlesSolvedInRow }}</span> <span class="separator">of</span> <span class="total">{{ requiredPuzzles }}</span> puzzles solved in a row
          </span>
          <span v-else-if="isSpeedChallenge">
            <span class="current">{{ puzzlesSolved }}</span> <span class="separator">of</span> <span class="total">{{ requiredPuzzles }}</span> puzzles solved
          </span>
          <span v-else-if="isMoveComboChallenge">
            Move combo: <span class="current">{{ comboCount }}</span> <span class="separator">of</span> <span class="total">{{ comboTarget }}</span>
          </span>
          <span v-else-if="isCheckmateChallenge">
            Win by checkmate
          </span>
          <span v-else>
            <span class="current">{{ puzzlesSolved }}</span> <span class="separator">of</span> <span class="total">{{ levelInfo.puzzle_count }}</span> puzzles solved
          </span>
        </span>
      </div>
    </div>
    
    <!-- Board overlay for timer timeout and completion -->
    <div class="board-modal-container invisible"></div>
  </div>
</template>

<script>
import { subscribe, dispatch } from '@blitz/events'
import ChessgroundBoard from '@blitz/components/chessground_board'
import MoveStatus from '@blitz/components/move_status'
import ComboCounter from '@blitz/components/puzzle_player/views/combo_counter'
import Instructions from '@blitz/components/puzzle_player/views/instructions'
import PuzzleHint from '@blitz/components/puzzle_player/views/puzzle_hint'
import ChessboardResizer from '@blitz/components/puzzle_player/views/chessboard_resizer'
import AdventurePuzzleSource from '@blitz/components/adventure_puzzle_player/adventure_puzzle_source'
import Timer from './timer.vue'
import ComboTimer from './combo_timer.vue'

export default {
  name: 'AdventureMode',
  
  data() {
    return {
      levelInfo: null,
      hasStarted: false,
      puzzlesSolved: 0,
      puzzlesSolvedInRow: 0,
      requiredPuzzles: 0,
      isWithoutMistakesChallenge: false,
      isSpeedChallenge: false,
      isMoveComboChallenge: false,
      isCheckmateChallenge: false,
      comboCount: 0,
      comboTarget: 0,
      comboDropTime: null,
      puzzlePlayer: null,
      setCompleted: false,
      completionMessage: '',
      startTime: null,
      timerExpired: false,
      completionTime: null,
      gameLost: false,
      gameLostMessage: 'Game over! Try again.',
      bestTime: null
    }
  },
  
  mounted() {
    this.initializeAdventureMode()
    this.setupEventListeners()
  },
  
  
  methods: {
    initializeAdventureMode() {
      const puzzlePlayerElement = document.getElementById('puzzle-player')
      if (!puzzlePlayerElement) return

      // Get puzzle data from data attributes
      const puzzlesData = puzzlePlayerElement.dataset.puzzles
      const levelInfoData = puzzlePlayerElement.dataset.levelInfo

      if (puzzlesData && levelInfoData) {
        this.levelInfo = JSON.parse(levelInfoData)
        this.isWithoutMistakesChallenge = this.levelInfo.challenge === 'without_mistakes'
        this.isSpeedChallenge = this.levelInfo.challenge === 'speed'
        this.isMoveComboChallenge = this.levelInfo.challenge === 'move_combo'
        this.isCheckmateChallenge = this.levelInfo.challenge === 'checkmate'
        this.requiredPuzzles = this.levelInfo.puzzle_count || 0
        this.puzzlesSolvedInRow = 0
        this.comboCount = 0
        this.comboTarget = this.levelInfo.combo_target || 30
        this.comboDropTime = this.levelInfo.combo_drop_time || null
        console.log('Adventure: levelInfo loaded:', this.levelInfo)
        
        // Initialize based on challenge type
        if (this.isCheckmateChallenge) {
          // For checkmate challenges, create board with correct options
          const puzzleData = JSON.parse(puzzlesData)
          console.log('Checkmate challenge - puzzle data:', puzzleData)
          if (puzzleData.position_fen) {
            console.log('Setting up checkmate position with FEN:', puzzleData.position_fen)
            // Create chessground board with correct FEN and orientation
            window.adventureChessgroundBoard = new ChessgroundBoard({
              fen: puzzleData.position_fen,
              intentOnly: false,
              orientation: 'white' // Show from white's perspective so black pieces are at bottom
            })
            new ChessboardResizer()
            new MoveStatus()
            new Instructions()
            new ComboCounter()
            new PuzzleHint()
            // Initialize adventure puzzle source for event handling
            new AdventurePuzzleSource()
            dispatch('adventure:level:loaded', this.levelInfo)
          } else {
            console.error('No position_fen found in puzzle data for checkmate challenge')
          }
        } else {
          // For regular challenges, create board with default options
          new ChessgroundBoard()
          new ChessboardResizer()
          new MoveStatus()
          new Instructions()
          new ComboCounter()
          new PuzzleHint()
          // Use adventure puzzle source
          new AdventurePuzzleSource()
          dispatch('adventure:level:loaded', this.levelInfo)
          dispatch('puzzles:fetched', JSON.parse(puzzlesData).puzzles)
        }
      }
    },
    
    setupEventListeners() {
      subscribe({
        'puzzles:start': () => {
          this.hasStarted = true
          this.startTime = Date.now()
        },
        'puzzle:solved': () => {
          this.puzzlesSolved++
        },
        'adventure:counter:update': (data) => {
          this.puzzlesSolvedInRow = data.puzzlesSolvedInRow
          this.requiredPuzzles = data.requiredPuzzles
        },
        'adventure:counter:reset': (data) => {
          this.puzzlesSolvedInRow = data.puzzlesSolvedInRow
          this.requiredPuzzles = data.requiredPuzzles
        },
        'adventure:combo:update': (data) => {
          this.comboCount = data.comboCount
          this.comboTarget = data.comboTarget
        },
        'adventure:combo:reset': (data) => {
          this.comboCount = data.comboCount
          this.comboTarget = data.comboTarget
        },
        'puzzles:complete': () => {
          console.log('Adventure: puzzles:complete received')
          this.handleSetComplete()
        },
        'game:won': () => {
          console.log('Adventure: game:won received, isCheckmateChallenge:', this.isCheckmateChallenge)
          if (this.isCheckmateChallenge) {
            console.log('Adventure: Calling handleSetComplete for checkmate challenge')
            this.handleSetComplete()
          }
        },
        'game:lost': () => {
          console.log('Adventure: game:lost received, isCheckmateChallenge:', this.isCheckmateChallenge)
          if (this.isCheckmateChallenge) {
            console.log('Adventure: Game lost, showing retry overlay')
            this.gameLost = true
            this.gameLostMessage = 'Game over! Try again.'
            this.showBoardOverlay()
          }
        },
        'game:stalemate': () => {
          console.log('Adventure: game:stalemate received, isCheckmateChallenge:', this.isCheckmateChallenge)
          if (this.isCheckmateChallenge) {
            console.log('Adventure: Stalemate, showing retry overlay')
            this.gameLost = true
            this.gameLostMessage = 'Stalemate! Try again.'
            this.showBoardOverlay()
          }
        },
        'game:draw': () => {
          console.log('Adventure: game:draw received, isCheckmateChallenge:', this.isCheckmateChallenge)
          if (this.isCheckmateChallenge) {
            console.log('Adventure: Draw, showing retry overlay')
            this.gameLost = true
            this.gameLostMessage = 'Game over: Draw'
            this.showBoardOverlay()
          }
        },
        'timer:stopped': () => {
          if (this.isSpeedChallenge) {
            this.timerExpired = true
            this.showBoardOverlay()
          }
        }
      })
    },
    
    async handleSetComplete() {
      if (!this.levelInfo) return
      
      try {
        // Calculate time spent in milliseconds
        const timeSpent = this.startTime ? (Date.now() - this.startTime) : null
        
        const response = await fetch(`/adventure/level/${this.levelInfo.level_number}/set/${this.levelInfo.set_index}/complete`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
          },
          body: JSON.stringify({
            puzzles_solved: this.levelInfo.puzzle_count,
            time_spent: timeSpent
          })
        })

        const result = await response.json()
        console.log('Backend response:', result)
        console.log('best_time_ms from backend:', result.best_time_ms)
        
        if (result.success) {
          this.setCompleted = true
          this.completionTime = timeSpent
          this.bestTime = result.best_time_ms
          this.showBoardOverlay()
        } else {
          this.setCompleted = true
          this.completionTime = timeSpent
          this.bestTime = null
          this.showBoardOverlay()
        }
      } catch (error) {
        console.error('Error completing set:', error)
        this.setCompleted = true
        this.completionTime = timeSpent
        this.bestTime = null
        this.showBoardOverlay()
      }
    },
    
    returnToHomepage() {
      window.location.href = '/'
    },
    
    retryLevel() {
      window.location.reload()
    },
    
    showBoardOverlay() {
      const el = document.querySelector('.board-modal-container')
      if (el) {
        el.style.display = ''
        el.classList.remove('invisible')
      }
    },
    
    formatTime(timeMs) {
      if (!timeMs) return '0.0s'
      const seconds = timeMs / 1000
      return `${(Math.round(seconds * 10) / 10).toFixed(1)}s`
    }
  },

  components: {
    Timer,
    ComboTimer
  }
}
</script>

<style scoped>
.adventure-mode {
  margin: 0;
  padding: 0;
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1;
  pointer-events: none;
}

.adventure-mode .adventure-header,
.adventure-mode .adventure-progress {
  pointer-events: auto;
}

.adventure-mode .adventure-header {
  text-align: center;
  margin-bottom: 20px;
}

.adventure-mode .adventure-header h2 {
  color: #ffffff;
  font-size: 24px;
  font-weight: 600;
  margin: 0 0 8px 0;
}

.adventure-mode .adventure-header p {
  color: #cccccc;
  font-size: 16px;
  margin: 0;
}

.adventure-mode .adventure-progress {
  text-align: center;
  padding: 15px 0;
  font-size: 16px;
  font-weight: 500;
  color: #ffffff;
  margin: 10px 0;
}

.adventure-mode .timer-section {
  margin-bottom: 15px;
}

.adventure-mode .combo-timer-section {
  margin-bottom: 15px;
}

.adventure-mode .adventure-progress .progress-text {
  display: inline-block;
  font-family: 'Courier New', 'Monaco', 'Menlo', monospace !important;
  font-variant-numeric: tabular-nums !important;
}

.adventure-mode .adventure-progress .progress-text * {
  font-family: inherit !important;
  font-variant-numeric: inherit !important;
}

.adventure-mode .adventure-progress .progress-text .solve-text .total {
  color: #ffffff;
  font-weight: 500;
  min-width: 2em;
  text-align: center;
  display: inline-block;
  font-family: inherit !important;
}

.adventure-mode .adventure-progress .progress-text .solved-text .current {
  color: #4CAF50;
  font-weight: 600;
  display: inline-block;
  min-width: 2em;
  text-align: center;
  font-family: inherit !important;
}

.adventure-mode .adventure-progress .progress-text .solved-text .separator {
  color: #ffffff;
  font-weight: 500;
  display: inline-block;
  min-width: 2em;
  text-align: center;
  font-family: inherit !important;
}

.adventure-mode .adventure-progress .progress-text .solved-text .total {
  color: #ffffff;
  font-weight: 500;
  min-width: 2em;
  text-align: center;
  display: inline-block;
  font-family: inherit !important;
}

/* Completion information underneath the board */
.adventure-mode .adventure-completion-info {
  text-align: center;
  pointer-events: auto;
}

.adventure-mode .adventure-completion-info .completion-message {
  color: #4CAF50;
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 15px;
}

.adventure-mode .adventure-completion-info .completion-time {
  color: #2c5aa0;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 8px;
}

.adventure-mode .adventure-completion-info .best-time {
  color: #4a90e2;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 20px;
}

.adventure-mode .adventure-completion-info .completion-button {
  background: #4a90e2;
  color: white;
  border: none;
  padding: 14px 28px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 8px;
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  transition: background-color 0.2s;
  min-width: 180px;
  min-height: 48px;
}

.adventure-mode .adventure-completion-info .completion-button:hover {
  background: #357abd;
}

.adventure-mode .adventure-completion-info .completion-button:active {
  background: #2c5aa0;
}

/* Timer expired section */
.adventure-mode .timer-expired-section {
  text-align: center;
  margin-bottom: 20px;
}

.adventure-mode .timer-expired-message {
  color: #ffb366;
  font-size: 40px;
  font-weight: bold;
  margin-bottom: 20px;
  font-family: 'Courier New', 'Monaco', 'Menlo', monospace;
}

.adventure-mode .retry-button {
  background: #4a90e2;
  color: white;
  border: none;
  padding: 14px 28px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 8px;
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  transition: background-color 0.2s;
  min-width: 120px;
  min-height: 48px;
}

.adventure-mode .retry-button:hover {
  background: #357abd;
}

.adventure-mode .retry-button:active {
  background: #2c5aa0;
}

/* Board overlay for timer timeout */
.adventure-mode .board-modal-container {
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.6);
  position: absolute;
  left: 0;
  top: 0;
  z-index: 2;
  opacity: 1;
  transition: opacity 150ms ease-in-out;
  pointer-events: all;
}

.adventure-mode .board-modal-container.invisible {
  opacity: 0;
  pointer-events: none;
}

/* Game lost section styles */
.adventure-mode .game-lost-section {
  text-align: center;
  padding: 20px 0;
}

.adventure-mode .game-lost-message {
  font-size: 18px;
  color: #ff6b6b;
  margin-bottom: 15px;
  font-weight: 600;
}

</style>
