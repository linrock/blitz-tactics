<template lang="pug">
.timer(:class="{ stopped: startTime === 0 }") {{ formattedElapsedTime }}

</template>

<script lang="ts">
  import { dispatch, subscribe, subscribeOnce, GameEvent } from '@blitz/events'
  import { formattedTime } from '@blitz/utils'

  const updateInterval = 37

  export default {
    data() {
      return {
        startTime: 0,
        nowTime: 0,
        isComplete: false,
      }
    },

    computed: {
      elapsedTimeMilliseconds(): number {
        return this.nowTime - this.startTime
      },

      // such as 0:00.0
      formattedElapsedTime(): string {
        return this.nowTime > 0 ? formattedTime(this.elapsedTimeMilliseconds) : '0.00.0'
      },
    },

    mounted() {
      let timerInterval: number

      subscribeOnce('move:try', () => {
        this.startTime = Date.now()
        timerInterval = window.setInterval(() => this.nowTime = Date.now(), updateInterval)
      })

      subscribe({
        [GameEvent.PUZZLES_COMPLETE]: () => {
          clearInterval(timerInterval)
          this.isComplete = true
          dispatch(GameEvent.TIMER_STOPPED, this.elapsedTimeMilliseconds)
        }
      })
    }
  }
</script>
