<template lang="pug">
.timer(:class="{ stopped: !hasStarted && !hasEnded, rewarded: isRewarded }")
  | {{ formattedTimeSeconds }}
</template>

<script lang="ts">
import { subscribe, subscribeOnce, GameEvent } from '@blitz/events'
import TimerMixin from '@blitz/components/timer_mixin'

const updateIntervalMs = 33   // timer updates this frequently
const rewardThreshold = 3     // combo this many puzzles to gain a time reward
const comboRewardMs = 3_000   // gain this much more time for puzzle combos

export default {
  mixins: [TimerMixin],

  mounted() {
    subscribeOnce('move:try', () => {
      // start the timer after the first player move
      this.startTimer(updateIntervalMs)
    })

    subscribe({
      [GameEvent.TIMER_STOP]: () => {
        this.gameHasEnded();
      },
      [GameEvent.MOVE_FAIL]: () => {
        // reset the puzzle combo when making mistakes
        this.resetCombo()
      },
      [GameEvent.PUZZLE_SOLVED]: () => {
        // increment puzzle combo and give a reward past a threshold
        this.incrementCombo()
        if (this.comboSize > 0 && this.comboSize % rewardThreshold === 0) {
          console.log(`combo size: ${this.comboSize}. give a reward!`)
          this.addTime(comboRewardMs)
          this.showReward()
        }
      },
      [GameEvent.PUZZLES_COMPLETE]: () => {
        // this happens when all the threes puzzles in a round have been completed
        this.gameHasEnded()
      },
    })
  }
}
</script>
