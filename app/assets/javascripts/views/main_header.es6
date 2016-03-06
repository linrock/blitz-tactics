{

  // Main header with intro, progress bar, instructions
  //
  class MainHeader extends Backbone.View {

    get el() {
      return ".main-header"
    }

    initialize() {
      this.listenTo(d, "puzzles:start", () => {
        this.$el.attr("data-state", "progress")
      })
      this.listenTo(d, "puzzle_sets:next", () => {
        this.$el.attr("data-state", "next-stage")
      })
    }

  }


  Views.MainHeader = MainHeader

}
