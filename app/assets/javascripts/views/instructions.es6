{

  class Instructions extends Backbone.View {

    get el() {
      return ".instructions"
    }

    initialize() {
      this.listenTo(d, "move:too_slow", () => {
        this.$el.addClass("smaller")
      })
      this.listenTo(d, "puzzles:start", () => {
        this.$el.fadeOut(50)
      })
    }

  }


  Views.Instructions = Instructions

}
