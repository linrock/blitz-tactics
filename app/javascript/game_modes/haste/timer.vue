<template lang="pug">
.timer(:class="{ stopped: !hasStarted && !hasEnded, penalized: isPenalized, rewarded: isRewarded }")
  | {{ formattedTimeSeconds }}
</template>

<script lang="ts">
import { dispatch, subscribe, subscribeOnce } from '@blitz/events'
import { formattedTimeSeconds } from '@blitz/utils'

const initialTimeMin = 3      // number of minutes on the clock initially
const updateIntervalMs = 100  // timer updates this frequently
const rewardThreshold = 10    // combo this many moves to gain time
const rewardMs = 7000         // gain this much time at the reward threshold
const comboRewardMs = 3000    // gain this much more time for maintaining combo
const penaltyMs = 30000       // lose this much time per mistake

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
      isPenalized: false,
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
      'move:success': () => {
        // gain time with higher combos
        this.comboSize += 1
        if (this.comboSize % rewardThreshold !== 0) {
          return
        }
        this.timeModifierMs += rewardMs
        this.timeModifierMs += (comboRewardMs * (this.comboSize / rewardThreshold - 1))
        this.isRewarded = true
        setTimeout(() => this.isRewarded = false, 250)
      },
      'move:fail': () => {
        // lose time when making mistakes
        this.comboSize = 0
        this.timeModifierMs -= penaltyMs
        this.isPenalized = true
        setTimeout(() => this.isPenalized = false, 250)
      },
      'puzzles:complete': () => {
        // this happens when all the haste puzzles in a round have been completed
        gameHasEnded()
      },
    })
  }
}
</script>
