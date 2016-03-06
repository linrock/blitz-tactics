{

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
      return ((Date.now() - this.startTime) / 1000).toFixed(1)
    }

    startTimer() {
      if (this.timer) {
        return
      }
      this.startTime = Date.now()
      this.timer = setInterval(() => { this.$timer.text(this.elapsedTime()) }, 100)
    }

    stopTimer() {
      if (this.timer) {
        clearInterval(this.timer)
        this.timer = false
      }
    }

    nextLap() {
      this.stopTimer()
      this.$laps.prepend(`<div>${this.elapsedTime()}</div>`)
      this.startTimer()
    }

  }


  Views.Timer = Timer

}
