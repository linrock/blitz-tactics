<template lang="pug">
.timer(:class="{ penalized: isPenalized, stopped: !hasStarted }")
  | {{ formattedTimeLeft }}

</template>

<script lang="ts">
import { dispatch, subscribe, subscribeOnce } from '@blitz/events'
import { formattedTimeSeconds } from '@blitz/utils'

const initialTimeMin = 5     // start with this many minutes on the clock
const updateInterval = 100   // timer updates this frequently
const penaltyMs = 30000      // lose this much time per mistake

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
    timeLeftMilliseconds(): number {
      return this.initialTimeMs - (this.nowTime - this.startTime) - this.lostTimeMs
    },
    formattedTimeLeft(): string {
      return this.hasEnded ? '0:00' : formattedTimeSeconds(this.timeLeftMilliseconds)
    }
  },

  mounted() {
    subscribeOnce('move:try', () => {
      const now = Date.now()
      this.hasStarted = true
      this.startTime = now
      this.nowTime = now
      const timerInterval = window.setInterval(() => {
        this.nowTime = Date.now()
        if (this.timeLeftMilliseconds <= 0) {
          this.hasEnded = true
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
      // TODO is this needed?
      'puzzles:complete': () => {
        dispatch('timer:stopped')
      }
    })
  },
}
</script>