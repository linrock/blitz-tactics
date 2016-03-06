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
      this.listenTo(d, "move:success", () => {
        let time = Date.now()
        if (time - this.timeSinceSuccess < 2500) {
          this.renderMarvelous()
        } else {
          this.renderPerfect()
        }
        this.timeSinceSuccess = time
      })
      this.listenTo(d, "move:fail", () => {
        this.renderFailure()
      })
    }

    renderPerfect() {
      this.$el.removeClass("fade-out")
      this.$el.html('<div class="success">Perfect!</div>')
      setTimeout(() => { this.$el.addClass("fade-out") }, 50)
    }

    renderMarvelous() {
      this.$el.removeClass("fade-out")
      this.$el.html('<div class="marvelous">Marvelous!</div>')
      setTimeout(() => { this.$el.addClass("fade-out") }, 50)
    }

    renderFailure() {
      this.$el.removeClass("fade-out")
      this.$el.html('<div class="fail">Miss</div>')
      setTimeout(() => { this.$el.addClass("fade-out") }, 50)
    }

  }


  Views.MoveStatus = MoveStatus

}
