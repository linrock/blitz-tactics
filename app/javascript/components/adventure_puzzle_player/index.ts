import { subscribe, dispatch } from '@blitz/events'
import { trackEvent } from '@blitz/utils'
import ChessgroundBoard from '../chessground_board'
import MoveStatus from '../move_status'
import ComboCounter from '../puzzle_player/views/combo_counter'
import Instructions from '../puzzle_player/views/instructions'
import PuzzleHint from '../puzzle_player/views/puzzle_hint'
import ChessboardResizer from '../puzzle_player/views/chessboard_resizer'
import AdventurePuzzleSource from './adventure_puzzle_source'

import './style.sass'

interface AdventureLevelInfo {
  level_number: number
  level_description: string
  set_index: number
  color_to_move: string
  rating_range: string
  puzzle_count: number
  success_criteria: string
}

/** The adventure puzzle player for playing adventure levels */
export default class AdventurePuzzlePlayer {
  private levelInfo: AdventureLevelInfo
  private puzzles: any[]

  constructor() {
    this.initializeAdventurePuzzlePlayer()
    this.setupEventListeners()
  }

  private initializeAdventurePuzzlePlayer() {
    const puzzlePlayerElement = document.getElementById('puzzle-player')
    if (!puzzlePlayerElement) {
      return
    }

    // Get puzzle data from data attributes
    const puzzlesData = puzzlePlayerElement.dataset.puzzles
    const levelInfoData = puzzlePlayerElement.dataset.levelInfo

    if (puzzlesData && levelInfoData) {
      this.puzzles = JSON.parse(puzzlesData)
      this.levelInfo = JSON.parse(levelInfoData)
      
      // Create all views first so they can subscribe to events
      new ChessgroundBoard
      new ChessboardResizer
      new MoveStatus
      new Instructions
      new ComboCounter
      new PuzzleHint

      // Create adventure puzzle source last so views are ready for events
      new AdventurePuzzleSource

      // Dispatch adventure-specific events
      dispatch('adventure:level:loaded', this.levelInfo)
      dispatch('puzzles:fetched', this.puzzles.puzzles)
    }
  }

  private setupEventListeners() {
    subscribe({
      'puzzle:solved': puzzle => {
        trackEvent(`adventure puzzle solved`, window.location.pathname, puzzle.id)
        this.handlePuzzleSolved(puzzle)
      },
      'puzzles:complete': () => {
        this.handleSetComplete()
      }
    })
  }

  private handlePuzzleSolved(puzzle: any) {
    // Track adventure-specific puzzle completion
    console.log(`Adventure puzzle solved: ${puzzle.id} in level ${this.levelInfo.level_number}, set ${this.levelInfo.set_index}`)
  }

  private handleSetComplete() {
    // Handle set completion
    console.log(`Adventure set ${this.levelInfo.set_index} in level ${this.levelInfo.level_number} completed!`)
    
    // Mark the set as completed
    this.completeSet()
  }

  private async completeSet() {
    try {
      const response = await fetch(`/adventure/level/${this.levelInfo.level_number}/set/${this.levelInfo.set_index}/complete`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.getAttribute('content') || ''
        },
        body: JSON.stringify({
          puzzles_solved: this.puzzles.puzzles.length
        })
      })

      const result = await response.json()
      
      if (result.success) {
        console.log('Set completed successfully!', result.message)
        
        // Show completion message
        if (result.level_completed) {
          alert('Congratulations! You completed the entire level!')
        } else {
          alert('Set completed! Great job!')
        }
        
        // Navigate back to level overview
        window.location.href = `/adventure/level/${this.levelInfo.level_number}`
      } else {
        console.error('Failed to complete set:', result.error)
        alert('Failed to save completion. Please try again.')
      }
    } catch (error) {
      console.error('Error completing set:', error)
      alert('Error saving completion. Please try again.')
    }
  }
}
