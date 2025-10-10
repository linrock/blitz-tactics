import { uciToMove } from '@blitz/utils'
import MiniChessboard from '@blitz/components/mini_chessboard'
import { solutionReplay } from '@blitz/utils/solution_replay'

// Solution player for recent puzzles - plays directly in miniboards
export class SolutionPlayer {
  private playingSolutions: Set<string> = new Set()

  constructor() {
    this.setupEventListeners()
  }

  private setupEventListeners() {
    // View solution buttons
    document.addEventListener('click', (e) => {
      const target = e.target as HTMLElement
      if (target && target.classList.contains('view-solution-btn')) {
        e.preventDefault()
        this.playSolutionInMiniboard(target)
      }
    })
  }

  private async playSolutionInMiniboard(button: HTMLElement) {
    const buttonEl = button as HTMLButtonElement
    const puzzleId = button.getAttribute('data-puzzle-id')
    const initialFen = button.getAttribute('data-initial-fen')
    const solutionLinesJson = button.getAttribute('data-solution-lines')
    
    if (!puzzleId || !initialFen) {
      console.error('Missing puzzle data for solution playback')
      return
    }

    // Prevent multiple simultaneous plays
    if (this.playingSolutions.has(puzzleId)) {
      return
    }
    
    // Change button text to indicate what's happening
    const originalText = button.textContent
    button.textContent = 'Showing solution...'

    // Update button state - fade out and disable to indicate processing
    button.style.opacity = '0.5'
    buttonEl.disabled = true
    this.playingSolutions.add(puzzleId)

    try {
      let solutionLines = null
      
      // Try to use embedded solution data first
      if (solutionLinesJson && solutionLinesJson.trim()) {
        solutionLines = JSON.parse(solutionLinesJson)
      } else {
        // Fallback: fetch solution data from server
        const response = await fetch(`/p/${puzzleId}.json`)
        const puzzleData = await response.json()
        solutionLines = puzzleData.puzzle_data?.lines || puzzleData.lines
      }
      
      if (!solutionLines) {
        console.warn('No solution data available')
        button.textContent = originalText || 'Show solution'
        button.style.opacity = '1'
        buttonEl.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      // The solutionReplay utility will handle extracting moves internally

      // Find the miniboard for this puzzle - look for both recent-puzzle-item and puzzle-item containers
      const puzzleItem = button.closest('.recent-puzzle-item') || button.closest('.puzzle-item')
      const miniboard = puzzleItem?.querySelector('.mini-chessboard')
      
      if (!miniboard) {
        console.error('Could not find miniboard for puzzle')
        button.textContent = originalText || 'Show solution'
        button.style.opacity = '1'
        buttonEl.disabled = false
        this.playingSolutions.delete(puzzleId)
        return
      }

      // Button remains faded during playback

      // Use the reusable solution replay utility
      solutionReplay.replaySolutionOnMiniboardWithCallback(
        miniboard as HTMLElement,
        solutionLines,
        () => {
          // Reset button when done
          button.textContent = originalText || 'Show solution'
          button.style.opacity = '1'
          buttonEl.disabled = false
          this.playingSolutions.delete(puzzleId)
        }
      )

    } catch (error) {
      console.error('Failed to load or parse solution data:', error)
      button.textContent = originalText || 'Show solution'
      button.style.opacity = '1'
      buttonEl.disabled = false
      this.playingSolutions.delete(puzzleId)
    }
  }











}

// Initialize solution player
export default () => {
  new SolutionPlayer()
}