<template lang="pug">
.timer(:class="{ stopped: !hasStarted && !hasEnded, penalized: isPenalized, rewarded: isRewarded }")
  | {{ formattedTimeSeconds }}
</template>

<script lang="ts">
import { subscribe } from '@blitz/events'
import TimerMixin from '@blitz/components/timer_mixin'

const updateIntervalMs = 100  // timer updates this frequently
const rewardThreshold = 10    // combo this many moves to gain time
const rewardMs = 7000         // gain this much time at the reward threshold
const comboRewardMs = 3000    // gain this much more time for maintaining combo
const penaltyMs = 30000       // lose this much time per mistake

export default {
  mixins: [TimerMixin],

  mounted() {
    // Start timer immediately for rook endgames mode
    this.startTimer(updateIntervalMs)

    subscribe({
      'move:success': () => {
        // gain time with higher combos
        this.incrementCombo()
        if (this.comboSize % rewardThreshold !== 0) {
          return
        }
        this.addTime(rewardMs)
        this.addTime(comboRewardMs * (this.comboSize / rewardThreshold - 1))
        this.showReward()
      },
      'move:fail': () => {
        // lose time when making mistakes
        this.resetCombo()
        this.subtractTime(penaltyMs)
        this.showPenalty()
      },
      'puzzles:complete': () => {
        // this happens when all the rook endgame puzzles in a round have been completed
        this.gameHasEnded()
      },
    })
  }
}
</script>