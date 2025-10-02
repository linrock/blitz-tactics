<template lang="pug">
.timer(:class="{ stopped: !hasStarted && !hasEnded }")
  | {{ formattedTimeLeft }}
</template>

<script lang="ts">
import { dispatch, subscribe, subscribeOnce, GameEvent } from '@blitz/events'
import { formattedTimeSeconds } from '@blitz/utils'

const updateInterval = 100       // timer updates this frequently

export default {
  props: {
    timeLimit: {
      type: Number,
      default: 60
    }
  },
  data() {
    return {
      hasStarted: false,
      hasEnded: false,
      initialTimeMs: 0,
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

  watch: {
    timeLimit(newTimeLimit) {
      this.initialTimeMs = newTimeLimit * 1000
      console.log('Timer time limit updated to:', newTimeLimit, 'seconds')
    }
  },

  mounted() {
    // Set the initial time from the prop
    this.initialTimeMs = this.timeLimit * 1000 // Convert seconds to milliseconds
    console.log('Timer initialized with time limit:', this.timeLimit, 'seconds (', this.initialTimeMs, 'ms)')

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
          dispatch(GameEvent.TIMER_STOPPED)
        }
      }, updateInterval)
    })

    subscribe({
      [GameEvent.PUZZLES_COMPLETE]: () => {
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
