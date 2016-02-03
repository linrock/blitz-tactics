{

  class Timer extends Backbone.View {

    get el() {
      return $(".timer")
    }

    initialize() {
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "puzzles:next", () => {
        if (this.startTime) {
          return
        }
        this.startTimer()
      })
    }

    startTimer() {
      this.startTime = Date.now()
      setInterval(() => {
        let elapsed = ((Date.now() - this.startTime) / 1000).toFixed(1)
        this.$el.text(elapsed)
      }, 100)
    }

  }


  Views.Timer = Timer

}
