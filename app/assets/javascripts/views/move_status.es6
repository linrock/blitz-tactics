{

  // Encouragement when successful, 
  // discouragement when making a wrong move
  //
  class MoveStatus extends Backbone.View {

    get el() {
      return ".move-status"
    }

    initialize() {
      this.timeSinceSuccess = Date.now()
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "move:success", _.bind(this.renderSuccess, this))
      this.listenTo(d, "move:fail", _.bind(this.renderFailure, this))
    }

    renderSuccess() {
      let time = Date.now()
      let tDiff = time - this.timeSinceSuccess
      if (tDiff < 2500) {
        this.renderPerfect()
      } else if (tDiff < 5000) {
        this.renderGreat()
      } else {
        this.renderGood()
      }
      this.timeSinceSuccess = time
    }

    renderFailure() {
      this.renderFadingMessage('<div class="fail">Miss</div>')
    }

    renderPerfect() {
      this.renderFadingMessage('<div class="perfect">Perfect!</div>')
    }

    renderGreat() {
      this.renderFadingMessage('<div class="great">Great!</div>')
    }

    renderGood() {
      this.renderFadingMessage('<div class="good">Good!</div>')
    }

    renderFadingMessage(html) {
      this.$el.removeClass("fade-out")
      this.$el.html(html)
      setTimeout(() => { this.$el.addClass("fade-out") }, 50)
    }

  }


  Views.MoveStatus = MoveStatus

}
