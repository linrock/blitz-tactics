<template lang="pug">
.quest-under-board.game-under-board
  .quest-info
    .level-info
      .level-number Level {{ levelNumber }}
      .success-criteria {{ successCriteria }}
    .puzzle-progress {{ numPuzzlesSolved }} / {{ totalPuzzles }} puzzles solved

  .quest-complete(v-if="hasFinished")
    .completion-message
      .title Level Complete!
      .description You've solved all puzzles in this level
    .action-buttons
      a.blue-button(href="/") Back to Homepage

  .make-a-move(v-if="!hasStarted") Make a move to start solving puzzles

</template>

<script lang="ts">
import PuzzlePlayer from '@blitz/components/puzzle_player'
import GameModeMixin from '@blitz/components/game_mode_mixin'
import { subscribe, dispatch } from '@blitz/events'



export default {
  mixins: [GameModeMixin],

  data() {
    return {
      numPuzzlesSolved: 0,
      totalPuzzles: 0,
      levelNumber: 0,
      successCriteria: '',
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
      'puzzles:status': ({ i }) => {
        this.numPuzzlesSolved = i + 1
      },
      'puzzles:complete': () => {
        this.hasFinished = true
        console.log('Quest level completed!')
      }
    })
  },
}
</script>
