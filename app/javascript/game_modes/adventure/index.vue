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
          <span class="current">{{ puzzlesSolved }}</span> of <span class="total">{{ levelInfo.puzzle_count }}</span> puzzles solved
        </span>
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

export default {
  name: 'AdventureMode',
  
  data() {
    return {
      levelInfo: null,
      hasStarted: false,
      puzzlesSolved: 0,
      puzzlePlayer: null
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
      
      console.log('Adventure: Completing set with levelInfo:', this.levelInfo)
      console.log('Adventure: URL will be:', `/adventure/level/${this.levelInfo.level_number}/set/${this.levelInfo.set_index}/complete`)
      
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
          if (result.level_completed) {
            alert('Congratulations! You completed the entire level!')
          } else {
            alert('Set completed! Great job!')
          }
          
          // Navigate back to level overview
          window.location.href = `/adventure/level/${this.levelInfo.level_number}`
        }
      } catch (error) {
        console.error('Error completing set:', error)
        alert('Error saving completion. Please try again.')
      }
    }
  }
}
</script>
