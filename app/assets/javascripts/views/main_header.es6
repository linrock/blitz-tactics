{

  // Main header with intro, progress bar, instructions
  //
  class MainHeader extends Backbone.View {

    get el() {
      return ".real-main-header"
    }

    initialize() {
      this.listenTo(d, "puzzles:start", () => {
        if (blitz.loggedIn) {
          this.$el.addClass("hidden");
        } else {
          this.$el.addClass("faded");
        }
      })
    }

  }


  Views.MainHeader = MainHeader

}
