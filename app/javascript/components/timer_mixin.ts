import { dispatch, subscribe, subscribeOnce } from '@blitz/events'
import { formattedTimeSeconds } from '@blitz/utils'

export default {
  data() {
    return {
      initialTimeMs: 3 * 60 * 1000, // 3 minutes default
      timeModifierMs: 0,
      hasStarted: false,
      hasEnded: false,
      startTime: 0,
      nowTime: 0,
      comboSize: 0,
      isRewarded: false,
      isPenalized: false,
      timerInterval: null as number | null,
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

  methods: {
    gameHasEnded() {
      this.hasEnded = true
      if (this.timerInterval !== null) {
        clearInterval(this.timerInterval)
        this.timerInterval = null
      }
      dispatch('timer:stopped')
    },

    startTimer(updateIntervalMs: number = 100) {
      const now = Date.now()
      this.startTime = now
      this.nowTime = now
      this.timerInterval = window.setInterval(() => {
        this.nowTime = Date.now()
        if (this.timeLeftMilliseconds <= 0) {
          this.gameHasEnded()
        }
      }, updateIntervalMs)
      this.hasStarted = true
    },

    showReward(duration: number = 250) {
      this.isRewarded = true
      setTimeout(() => this.isRewarded = false, duration)
    },

    showPenalty(duration: number = 250) {
      this.isPenalized = true
      setTimeout(() => this.isPenalized = false, duration)
    },

    resetCombo() {
      this.comboSize = 0
    },

    incrementCombo() {
      this.comboSize += 1
    },

    addTime(timeMs: number) {
      this.timeModifierMs += timeMs
    },

    subtractTime(timeMs: number) {
      this.timeModifierMs -= timeMs
    }
  }
} 