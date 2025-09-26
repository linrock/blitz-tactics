<template lang="pug">
.timer(:class="{ stopped: !hasStarted && !hasEnded }")
  | {{ formattedTimeLeft }}
</template>

<script lang="ts">
import { dispatch, subscribe, subscribeOnce } from '@blitz/events'
import { formattedTimeSeconds } from '@blitz/utils'

const initialTimeMs = 60 * 1000  // 60 seconds
const updateInterval = 100       // timer updates this frequently

export default {
  data() {
    return {
      hasStarted: false,
      hasEnded: false,
      initialTimeMs: initialTimeMs,
      startTime: 0,
      nowTime: 0,
      timerInterval: null as number | null,
    }
  },

  computed: {
    timeLeftMilliseconds(): number {
      return this.initialTimeMs - (this.nowTime - this.startTime)
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
      this.timerInterval = window.setInterval(() => {
        this.nowTime = Date.now()
        if (this.timeLeftMilliseconds <= 0) {
          this.hasEnded = true
          if (this.timerInterval !== null) {
            clearInterval(this.timerInterval)
            this.timerInterval = null
          }
          dispatch('timer:stopped')
        }
      }, updateInterval)
    })

    subscribe({
      'puzzles:complete': () => {
        if (this.timerInterval !== null) {
          clearInterval(this.timerInterval)
          this.timerInterval = null
        }
        this.hasEnded = true
      }
    })
  },

  beforeUnmount() {
    if (this.timerInterval !== null) {
      clearInterval(this.timerInterval)
    }
  }
}
</script>

<style scoped>
.timer {
  font-size: 40px;
  margin-bottom: 0.5rem;
  transition: opacity 0.25s ease, color 0.25s ease;
  font-family: 'Courier New', 'Monaco', 'Menlo', monospace;
  font-variant-numeric: tabular-nums;
}

.timer.stopped {
  opacity: 0.3;
}
</style>
