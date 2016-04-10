{

  class Onboarding extends Backbone.View {

    get el() {
      return ".onboarding"
    }

    initialize() {
      this.listenTo(d, "puzzles:start", () => {
        this.$el.addClass("invisible")
      })
    }

  }


  Views.Onboarding = Onboarding

}
