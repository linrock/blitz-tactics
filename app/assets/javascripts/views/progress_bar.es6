{

  // How close you are to the next round
  //
  class ProgressBar extends Backbone.View {

    get el() {
      return ".progress-bar"
    }

    initialize() {
      this.$progress = this.$(".progress")
      this.complete = false
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "progress:update", (percent) => {
        if (this.complete) {
          return
        }
        this.updateProgress(percent)
      })
    }

    updateProgress(percent) {
      this.$progress.width(`${percent}%`)
      if (percent >= 100) {
        this.$progress.addClass("complete")
        this.complete = true
      }
    }

  }


  Views.ProgressBar = ProgressBar

}
