<template>
  <div class="combo-timer" :class="{ stopped: !hasStarted && !hasEnded }">
    {{ formattedTimeLeft }}
  </div>
</template>

<script>
import { dispatch, subscribe, subscribeOnce } from '@blitz/events'
import { formattedTimeSeconds } from '@blitz/utils'

const updateInterval = 100 // timer updates this frequently

export default {
  name: 'ComboTimer',
  props: {
    dropTime: {
      type: Number,
      default: null
    }
  },
  data() {
    return {
      hasStarted: false,
      hasEnded: false,
      initialTimeMs: 0,
      startTime: 0,
      nowTime: 0,
      timerInterval: null,
    }
  },
  computed: {
    timeLeftMilliseconds() {
      const t = this.initialTimeMs - (this.nowTime - this.startTime)
      return t < 0 ? 0 : t
    },
    formattedTimeLeft() {
      return this.hasEnded ? '0:00' : formattedTimeSeconds(this.timeLeftMilliseconds)
    }
  },
  mounted() {
    // Initialize the timer with the drop time (only if dropTime is configured)
    if (this.dropTime !== null) {
      this.initialTimeMs = this.dropTime * 1000
    }
    
    // Start timer on first move (only if dropTime is configured)
    if (this.dropTime !== null) {
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
    }

    // Restart timer when combo is updated (puzzle solved) - only if dropTime is configured
    if (this.dropTime !== null) {
      subscribe({
        'adventure:combo:timer:restart': (data) => {
          if (this.timerInterval !== null) {
            clearInterval(this.timerInterval)
            this.timerInterval = null
          }
          
          // Update drop time if provided
          if (data.dropTime) {
            this.initialTimeMs = data.dropTime * 1000
          }
          
          // Restart the timer
          const now = Date.now()
          this.hasStarted = true
          this.hasEnded = false
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
        },
        'puzzles:complete': () => {
          if (this.timerInterval !== null) {
            clearInterval(this.timerInterval)
            this.timerInterval = null
          }
        }
      })
    }
  },
  beforeUnmount() {
    if (this.timerInterval !== null) {
      clearInterval(this.timerInterval)
    }
  }
}
</script>

<style scoped>
.combo-timer {
  font-size: 40px;
  font-weight: bold;
  color: #fff;
  text-shadow: 0 0 8px rgba(0,0,0,0.9);
  transition: all 0.25s ease-out;
}

.combo-timer.stopped {
  opacity: 0.3;
}
</style>
