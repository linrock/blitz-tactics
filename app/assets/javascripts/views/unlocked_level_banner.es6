{

  // Main header with intro, progress bar, instructions
  //
  class UnlockedLevelBanner extends Backbone.View {

    get el() {
      return ".next-stage"
    }

    initialize() {
      this.listenTo(d, "level:unlocked", () => {
        this.$el.removeClass("invisible")
        // TODO One view for all level stuff?
        $(".level-name").addClass("invisible")
      })
    }

  }


  Views.UnlockedLevelBanner = UnlockedLevelBanner

}
