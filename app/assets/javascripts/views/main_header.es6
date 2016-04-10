{

  // Main header with intro, progress bar, instructions
  //
  class MainHeader extends Backbone.View {

    get el() {
      return ".real-main-header"
    }

    initialize() {
      this.listenTo(d, "puzzles:start", () => {
        this.$el.attr("data-state", "progress")

        if (this.$(".user-area.logged-in").length) {
          this.$(".user-area.logged-in").fadeOut(100)
        } else {
          this.$(".user-area").addClass("slight-fade")
        }

        this.$el.addClass("hidden");
      })
    }

  }


  Views.MainHeader = MainHeader

}
