<template lang="pug">
.above-board
  .instructions(:class=`{ invisible: !showInstructions && !showGameOver}`)
    | {{ showInstructions ? instructionsText : showGameOver ? gameOverText : '' }}
.chessground-board
  .piece-promotion-modal-mount
  .chessground
  .board-modal-container.invisible(style="display: none")
.actions
  button.dark-button(@click="resetPosition()") Reset position
  button.dark-button(@click="analyzeOnLichess()") Analyze on Lichess

</template>

<script lang="ts">
import { dispatch, subscribe } from '@blitz/events'
import PositionTrainerPlayer from '@blitz/components/position_trainer_player'
import './style.sass'

let positionTrainerPlayer: PositionTrainerPlayer

export default {
  data() {
    return {
      showInstructions: true,
      showGameOver: false,
      instructionsText: '',
      gameOverText: ''
    }
  },

  methods: {
    resetPosition() {
      dispatch('position:reset')
    },
    analyzeOnLichess() {
      if (positionTrainerPlayer) {
        positionTrainerPlayer.analyzeOnLichess()
      }
    },
  },

  mounted() {
    // Subscribe to instruction updates first
    subscribe({
      'instructions:set': (text: string) => {
        this.instructionsText = text
        this.showInstructions = true
        this.showGameOver = false
      },
      'instructions:hide': () => {
        this.showInstructions = false
      }
    })
    
    // Initialize the position trainer player after subscribing to events
    positionTrainerPlayer = new PositionTrainerPlayer()
  },

  beforeUnmount() {
    if (positionTrainerPlayer) {
      positionTrainerPlayer.destroy()
    }
  }
}
</script>
