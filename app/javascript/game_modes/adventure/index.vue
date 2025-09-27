<template>
  <div class="adventure-mode" v-if="levelInfo">
    <div class="adventure-header">
      <h2>Level {{ levelInfo.level_number }}-{{ levelInfo.set_index }}: {{ levelInfo.level_description }}</h2>
    </div>
    
    <div class="adventure-progress">
      <div v-if="isSpeedChallenge" class="timer-section">
        <timer></timer>
      </div>
      <div v-if="isMoveComboChallenge && comboDropTime !== null" class="combo-timer-section">
        <combo-timer :drop-time="comboDropTime"></combo-timer>
      </div>
      <div class="progress-text">
        <span v-if="!hasStarted" class="solve-text">
          <span v-if="isWithoutMistakesChallenge">
            Solve <span class="total">{{ requiredPuzzles }}</span> puzzles without mistakes
          </span>
          <span v-else-if="isSpeedChallenge">
            Solve <span class="total">{{ requiredPuzzles }}</span> puzzles in 60 seconds
          </span>
          <span v-else-if="isMoveComboChallenge">
            Reach move combo <span class="total">{{ comboTarget }}</span>
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
          <span v-else>
            <span class="current">{{ puzzlesSolved }}</span> <span class="separator">of</span> <span class="total">{{ levelInfo.puzzle_count }}</span> puzzles solved
          </span>
        </span>
      </div>
    </div>
    
    <div v-if="setCompleted" class="adventure-completion-overlay">
      <div class="completion-content">
        <div class="completion-message">{{ completionMessage }}</div>
        <button class="completion-button" @click="returnToHomepage">Return to Homepage</button>
      </div>
    </div>
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
      comboCount: 0,
      comboTarget: 0,
      comboDropTime: null,
      puzzlePlayer: null,
      setCompleted: false,
      completionMessage: ''
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
        this.requiredPuzzles = this.levelInfo.puzzle_count || 0
        this.puzzlesSolvedInRow = 0
        this.comboCount = 0
        this.comboTarget = this.levelInfo.combo_target || 30
        this.comboDropTime = this.levelInfo.combo_drop_time || null
        console.log('Adventure: levelInfo loaded:', this.levelInfo)
        
        // Create all puzzle player components first
        new ChessgroundBoard()
        new ChessboardResizer()
        new MoveStatus()
        new Instructions()
        new ComboCounter()
        new PuzzleHint()
        
        // Create adventure puzzle source last so it can listen to events
        new AdventurePuzzleSource()

        // Dispatch events to load puzzles
        dispatch('adventure:level:loaded', this.levelInfo)
        dispatch('puzzles:fetched', JSON.parse(puzzlesData).puzzles)
      }
    },
    
    setupEventListeners() {
      subscribe({
        'puzzles:start': () => {
          this.hasStarted = true
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
          this.handleSetComplete()
        }
      })
    },
    
    async handleSetComplete() {
      if (!this.levelInfo) return
      
      try {
        const response = await fetch(`/adventure/level/${this.levelInfo.level_number}/set/${this.levelInfo.set_index}/complete`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
          },
          body: JSON.stringify({
            puzzles_solved: this.levelInfo.puzzle_count
          })
        })

        const result = await response.json()
        
        if (result.success) {
          this.setCompleted = true
          if (result.level_completed) {
            this.completionMessage = 'Congratulations! You completed the entire level!'
          } else {
            this.completionMessage = 'Set completed! Great job!'
          }
        } else {
          this.setCompleted = true
          this.completionMessage = 'Set completed! Great job!'
        }
      } catch (error) {
        console.error('Error completing set:', error)
        this.setCompleted = true
        this.completionMessage = 'Set completed! Great job!'
      }
    },
    
    returnToHomepage() {
      window.location.href = '/'
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

.adventure-mode .adventure-completion-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.8);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 9999;
  pointer-events: auto;
}

.adventure-mode .adventure-completion-overlay .completion-content {
  text-align: center;
  background: rgba(255, 255, 255, 0.95);
  padding: 30px;
  border-radius: 12px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
  min-width: 300px;
  min-height: 150px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.adventure-mode .adventure-completion-overlay .completion-content .completion-message {
  color: #4CAF50;
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 20px;
  min-height: 30px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.adventure-mode .adventure-completion-overlay .completion-content .completion-button {
  background: #4CAF50;
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

.adventure-mode .adventure-completion-overlay .completion-content .completion-button:hover {
  background: #45a049;
}

.adventure-mode .adventure-completion-overlay .completion-content .completion-button:active {
  background: #3d8b40;
}

</style>
