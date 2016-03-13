{

  // Button that lets you go to the next stage/puzzle set
  //
  class NextStageButton extends Backbone.View {

    get el() {
      return ".next-stage"
    }

    initialize() {
      this.$button = this.$(".blue-button")
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "level:unlocked", (href) => {
        this.$button.attr("href", href)
      })
    }

  }


  Views.NextStageButton = NextStageButton

}
