{

  const updateInterval = 500

  // Amount of time spent on this lap so far
  //
  class Timer extends Backbone.View {

    get el() {
      return ".times"
    }

    initialize() {
      this.listenForEvents()
      this.$timer = this.$(".timer")
      this.$laps = this.$(".laps")
      this.timer = false
    }

    listenForEvents() {
      this.listenTo(d, "puzzles:next", () => {
        if (this.startTime) {
          return
        }
        this.startTimer()
      })
      this.listenTo(d, "puzzles:lap", () => {
        this.nextLap()
      })
    }

    elapsedTime() {
      return ~~((Date.now() - this.startTime) / 1000)
    }

    formattedTime(integer) {
      let minutes = ~~( integer / 60 )
      let seconds = integer % 60
      return `${minutes}:${("0" + seconds).slice(-2)}`
    }

    formattedElapsed() {
      return this.formattedTime(this.elapsedTime())
    }

    startTimer() {
      if (this.timer) {
        return
      }
      this.startTime = Date.now()
      this.timer = setInterval(() => { this.$timer.text(this.formattedElapsed()) }, updateInterval)
    }

    stopTimer() {
      if (this.timer) {
        clearInterval(this.timer)
        this.timer = false
      }
    }

    nextLap() {
      this.stopTimer()
      this.$laps.prepend(`<div>${this.formattedElapsed()}</div>`)
      this.startTimer()
    }

  }


  Views.Timer = Timer

}
