{

  const updateInterval = 50

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
      this.listenTo(d, "puzzles:start", _.bind(this.startTimer, this))
      this.listenTo(d, "puzzles:next", _.bind(this.startTimer, this))
      this.listenTo(d, "puzzles:lap", _.bind(this.nextLap, this))
    }

    elapsedTime() {
      return ~~(( Date.now() - this.startTime) / 1000 )
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
      if (this.startTime || this.timer) {
        return
      }
      let lastElapsed
      this.startTime = Date.now()
      this.timer = setInterval(() => {
        let elapsed = this.formattedElapsed()
        if (elapsed != lastElapsed) {
          lastElapsed = elapsed
          this.$timer.text(elapsed)
        }
      }, updateInterval)
    }

    stopTimer() {
      if (this.timer) {
        clearInterval(this.timer)
        this.timer = false
      }
    }

    nextLap() {
      if (this.elapsedTime() === 0) {
        return
      }
      this.stopTimer()
      this.$laps.prepend(`<div>${this.formattedElapsed()}</div>`)
      this.notify()
      this.startTime = false
      this.startTimer()
    }

    notify() {
      d.trigger("round:complete", blitz.levelId, {
        time_elapsed: this.elapsedTime()
      })
    }

  }


  Views.Timer = Timer

}
