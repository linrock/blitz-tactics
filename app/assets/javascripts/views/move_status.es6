{

  // Encouragement when successful, 
  // discouragement when making a wrong move
  //
  class MoveStatus extends Backbone.View {

    get el() {
      return $(".move-status")
    }

    initialize() {
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "move:success", () => {
        this.$el.removeClass("fade-out")
        this.$el.html('<div class="success">Perfect!</div>')
        setTimeout(() => { this.$el.addClass("fade-out") }, 50)
      })
      this.listenTo(d, "move:fail", () => {
        this.$el.removeClass("fade-out")
        this.$el.html('<div class="fail">Miss</div>')
        setTimeout(() => { this.$el.addClass("fade-out") }, 50)
      })
    }

  }


  Views.MoveStatus = MoveStatus

}
