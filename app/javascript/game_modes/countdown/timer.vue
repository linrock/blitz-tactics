<template>
  <div class="timer" :class="{ penalized: isPenalized, stopped: !hasStarted }">
    {{ formattedTimeLeft }}
  </div>
</template>

<script>
import { dispatch, subscribe, subscribeOnce } from '@blitz/store'
import { formattedTimeSeconds } from '@blitz/utils'

const initialTimeMin = 5     // start with this many minutes on the clock
const updateInterval = 100   // timer updates this frequently
const penaltyMs = 30000      // lose this much time per mistake

let timerInterval

export default {
  data() {
    return {
      hasStarted: false,
      hasEnded: false,
      isPenalized: false,
      initialTimeMs: initialTimeMin * 60 * 1000 + 500,  // 5 min + 0.5s
      lostTimeMs: 0,
      startTime: 0,
      nowTime: 0,
    }
  },

  computed: {
    timeLeftMilliseconds() {
      return this.initialTimeMs - (this.nowTime - this.startTime) - this.lostTimeMs
    },
    formattedTimeLeft() {
      if (this.hasEnded) {
        return '0:00'
      }
      return formattedTimeSeconds(this.timeLeftMilliseconds)
    }
  },

  mounted() {
    subscribeOnce(`move:try`, () => {
      const now = Date.now()
      this.hasStarted = true
      this.startTime = now
      this.nowTime = now
      timerInterval = window.setInterval(() => {
        this.nowTime = Date.now()
        if (this.timeLeftMilliseconds <= 0) {
          this.hasEnded = false
          clearInterval(timerInterval)
          dispatch('timer:stopped')
        }
      }, updateInterval)
    })

    subscribe({
      'move:fail': () => {
        this.lostTimeMs += penaltyMs
        this.isPenalized = true
        setTimeout(() => this.isPenalized = false, 200)
      },
      'puzzles:complete': () => {
        dispatch('timer:stopped')
      }
    })
  },
}
</script>