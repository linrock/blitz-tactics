<template>
  <div class="adventure-mode" v-if="levelInfo">
    <div class="adventure-header">
      <h2>Level {{ levelInfo.level_number }}: {{ levelInfo.level_description }}</h2>
      <p>Set {{ levelInfo.set_index }} - {{ levelInfo.puzzle_count }} puzzles</p>
    </div>
    
    <div class="adventure-progress">
      <div class="progress-text">
        <span v-if="!hasStarted" class="solve-text">
          Solve <span class="total">{{ levelInfo.puzzle_count }}</span> puzzles
        </span>
        <span v-else class="solved-text">
          <span class="current">{{ puzzlesSolved }}</span> <span class="separator">of</span> <span class="total">{{ levelInfo.puzzle_count }}</span> puzzles solved
        </span>
      </div>
    </div>
    
    <div v-if="setCompleted" class="adventure-completion">
      <div class="completion-message">{{ completionMessage }}</div>
      <button class="completion-button" @click="returnToHomepage">Return to Homepage</button>
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

export default {
  name: 'AdventureMode',
  
  data() {
    return {
      levelInfo: null,
      hasStarted: false,
      puzzlesSolved: 0,
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
  }
}
</script>

<style scoped>
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

.adventure-mode .adventure-completion {
  text-align: center;
  padding: 20px 0;
  margin-top: 20px;
}

.adventure-mode .adventure-completion .completion-message {
  color: #4CAF50;
  font-size: 18px;
  font-weight: 600;
  margin-bottom: 15px;
}

.adventure-mode .adventure-completion .completion-button {
  background: #4CAF50;
  color: white;
  border: none;
  padding: 12px 24px;
  font-size: 16px;
  font-weight: 600;
  border-radius: 6px;
  cursor: pointer;
  text-decoration: none;
  display: inline-block;
  transition: background-color 0.2s;
}

.adventure-mode .adventure-completion .completion-button:hover {
  background: #45a049;
}

.adventure-mode .adventure-completion .completion-button:active {
  background: #3d8b40;
}
</style>
