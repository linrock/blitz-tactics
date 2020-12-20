<template lang="pug">
.timer(:class="{ stopped: !hasStarted && !hasEnded, rewarded: isRewarded }")
  | {{ formattedTimeSeconds }}
</template>

<script lang="ts">
import { dispatch, subscribe, subscribeOnce } from '@blitz/events'
import { formattedTimeSeconds } from '@blitz/utils'

const initialTimeMin = 3      // number of minutes on the clock initially
const updateIntervalMs = 33   // timer updates this frequently
const rewardThreshold = 3     // combo this many puzzles to gain a time reward
const comboRewardMs = 3_000   // gain this much more time for puzzle combos

export default {
  data() {
    return {
      initialTimeMs: initialTimeMin * 60 * 1000,
      timeModifierMs: 0,
      hasStarted: false,
      hasEnded: false,
      startTime: 0,
      nowTime: 0,
      comboSize: 0,
      isRewarded: false,
    }
  },

  computed: {
    timeLeftMilliseconds(): number {
      const t = this.initialTimeMs - (this.nowTime - this.startTime) + this.timeModifierMs
      return t < 0 ? 0 : t
    },
    formattedTimeSeconds(): string {
      return formattedTimeSeconds(this.timeLeftMilliseconds)
    },
  },

  mounted() {
    let timerInterval
    const gameHasEnded = () => {
      this.hasEnded = true
      if (typeof timerInterval !== 'undefined') {
        clearInterval(timerInterval)
        timerInterval = undefined
      }
      dispatch('timer:stopped')
    }
    subscribeOnce('move:try', () => {
      // start the timer after the first player move
      const now = Date.now()
      this.startTime = now
      this.nowTime = now
      timerInterval = window.setInterval(() => {
        this.nowTime = Date.now()
        if (this.timeLeftMilliseconds <= 0) {
          gameHasEnded()
        }
      }, updateIntervalMs)
      this.hasStarted = true
    })
    subscribe({
      'timer:stop': () => {
        gameHasEnded();
      },
      'move:fail': () => {
        // reset the puzzle combo when making mistakes
        this.comboSize = 0
      },
      'puzzle:solved': () => {
        // increment puzzle combo and give a reward past a threshold
        this.comboSize += 1
        if (this.comboSize > 0 && this.comboSize % rewardThreshold === 0) {
          console.log(`combo size: ${this.comboSize}. give a reward!`)
          this.isRewarded = true
          this.timeModifierMs += comboRewardMs
          setTimeout(() => this.isRewarded = false, 250)
        }
      },
      'puzzles:complete': () => {
        // this happens when all the threes puzzles in a round have been completed
        gameHasEnded()
      },
    })
  }
}
</script>
