<template lang="pug">
.quest-under-board.game-under-board
  .quest-info
    .level-info
      .success-criteria {{ successCriteria }}
    .puzzle-progress {{ numPuzzlesSolved }} / {{ puzzlesRequired }} puzzles solved

  .quest-complete(v-if="hasFinished")
    .completion-message
      .title Level Complete!
      .description You've solved all puzzles in this level
    .action-buttons
      a.blue-button(href="/") Back to Homepage

</template>

<script lang="ts">
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { subscribe, dispatch } from '@blitz/events'
import { questLevelCompleted } from '@blitz/api/requests'


export default {
  mixins: [GameModeMixin],

  data() {
    return {
      numPuzzlesSolved: 0,
      totalPuzzles: 0,
      puzzlesRequired: 0,
      levelNumber: 0,
      successCriteria: '',
      levelId: 0,
      startTime: null,
      completionSent: false,
    }
  },

  mounted() {
    // Get quest data from the page
    const puzzlePlayerElement = document.getElementById('puzzle-player')
    
    if (puzzlePlayerElement) {
      const puzzlesData = puzzlePlayerElement.dataset.puzzles
      const levelInfoData = puzzlePlayerElement.dataset.levelInfo
      
      if (puzzlesData && levelInfoData) {
        try {
          const puzzles = JSON.parse(puzzlesData)
          const levelInfo = JSON.parse(levelInfoData)
          
          this.totalPuzzles = puzzles.puzzles.length
          this.levelNumber = levelInfo.level_number
          this.successCriteria = levelInfo.success_criteria
          this.levelId = levelInfo.level_id
          
          // Parse success criteria to extract required puzzles
          this.puzzlesRequired = this.parsePuzzlesRequired(levelInfo.success_criteria)
          
          // Create puzzle player with quest data
          const puzzlePlayer = new PuzzlePlayer({
            shuffle: false,
            loopPuzzles: false,
            noHint: false,
            mode: 'quest'
          })
          
          // Dispatch puzzle data
          dispatch('puzzles:fetched', puzzles.puzzles)
        } catch (error) {
          console.error('Quest Vue: Error parsing data:', error)
        }
      }
    }
    
    const commonSubscriptions = this.setupCommonSubscriptions()
    
    subscribe({
      ...commonSubscriptions,
      'puzzles:status': async ({ i }) => {
        this.numPuzzlesSolved = i + 1
        
        // Check if we've reached the required number of puzzles
        if (this.numPuzzlesSolved >= this.puzzlesRequired && !this.completionSent && this.levelId) {
          this.completionSent = true
          this.hasFinished = true
          console.log(`Quest level completed! Solved ${this.numPuzzlesSolved}/${this.puzzlesRequired} required puzzles`)
          
          // Send completion request to server
          const timeTaken = this.startTime ? (Date.now() - this.startTime) / 1000 : undefined
          
          try {
            const result = await questLevelCompleted(this.levelId, this.numPuzzlesSolved, timeTaken)
            console.log('Quest level completion result:', result)
            
            if (result.success) {
              if (result.world_completed) {
                console.log('🎉 World completed!', result.message)
              } else {
                console.log('✅ Level completed!', result.message)
              }
            } else {
              console.log('Quest completion failed:', result.error)
            }
          } catch (error) {
            console.error('Error completing quest level:', error)
          }
        }
      },
      'puzzles:start': () => {
        this.startTime = Date.now()
      }
    })
  },
  
  methods: {
    parsePuzzlesRequired(successCriteria: string): number {
      // Parse "Solve X puzzles" format
      const match = successCriteria.match(/Solve (\d+) puzzle/)
      if (match) {
        return parseInt(match[1], 10)
      }
      // Fallback to total puzzles if parsing fails
      return this.totalPuzzles
    }
  }
}
</script>
