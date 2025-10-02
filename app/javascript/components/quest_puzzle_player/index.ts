import { subscribe, dispatch } from '@blitz/events'
import { trackEvent } from '@blitz/utils'
import ChessgroundBoard from '../chessground_board'
import MoveStatus from '../move_status'
import ComboCounter from '../puzzle_player/views/combo_counter'
import Instructions from '../puzzle_player/views/instructions'
import PuzzleHint from '../puzzle_player/views/puzzle_hint'
import ChessboardResizer from '../puzzle_player/views/chessboard_resizer'
import QuestPuzzleSource from './quest_puzzle_source'

import './style.sass'

interface QuestLevelInfo {
  world_id: number
  world_description: string
  level_id: number
  level_number: number
  success_criteria: string
  puzzle_count: number
}

/** The quest puzzle player for playing quest world levels */
export default class QuestPuzzlePlayer {
  private levelInfo: QuestLevelInfo
  private puzzles: any[]

  constructor() {
    this.initializeQuestPuzzlePlayer()
    this.setupEventListeners()
  }

  private initializeQuestPuzzlePlayer() {
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

      // Create quest puzzle source last so views are ready for events
      new QuestPuzzleSource

      // Dispatch quest-specific events
      dispatch(GameEvent.QUEST_LEVEL_LOADED, this.levelInfo)
      dispatch(GameEvent.PUZZLES_FETCHED, this.puzzles.puzzles)
    }
  }

  private setupEventListeners() {
    subscribe({
      [GameEvent.PUZZLE_SOLVED]: puzzle => {
        trackEvent(`quest puzzle solved`, window.location.pathname, puzzle.id)
        this.handlePuzzleSolved(puzzle)
      },
      [GameEvent.PUZZLES_COMPLETE]: () => {
        this.handleLevelComplete()
      }
    })
  }

  private handlePuzzleSolved(puzzle: any) {
    // Track quest-specific puzzle completion
    console.log(`Quest puzzle solved: ${puzzle.id} in level ${this.levelInfo.level_number}`)
  }

  private handleLevelComplete() {
    // Handle level completion
    console.log(`Quest level ${this.levelInfo.level_number} completed!`)
    
    // You could add logic here to:
    // - Mark the level as completed for the user
    // - Show completion message
    // - Navigate to next level or back to homepage
  }
}
