{

  // How close you are to the next round
  //
  class ProgressBar extends Backbone.View {

    get el() {
      return $(".progress-bar")
    }

    initialize() {
      this.$progress = this.$(".progress")
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "progress:update", (percent) => {
        this.updateProgress(percent)
      })
    }

    updateProgress(percent) {
      this.$progress.width(`${percent}%`)
    }

  }


  Views.ProgressBar = ProgressBar

}
