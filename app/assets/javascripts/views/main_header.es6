{

  // Main header hides for logged-in users, and fades for logged out
  //
  class MainHeader extends Backbone.View {

    get el() {
      return ".main-header"
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
