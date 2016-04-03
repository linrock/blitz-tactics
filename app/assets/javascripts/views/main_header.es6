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
        $(".user-name").fadeOut(100)
      })
      this.listenTo(d, "level:unlocked", () => {
        this.$el.attr("data-state", "next-stage")
      })
    }

  }


  Views.MainHeader = MainHeader

}
