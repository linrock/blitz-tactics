{

  class Instructions extends Backbone.View {

    get el() {
      return ".instructions"
    }

    initialize() {
      this.listenTo(d, "puzzles:start", () => {
        this.$el.fadeOut(50)
      })
    }

  }


  Views.Instructions = Instructions

}
