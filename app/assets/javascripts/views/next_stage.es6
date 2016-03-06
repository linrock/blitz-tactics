{

  // Button that lets you go to the next stage/puzzle set
  //
  class NextStage extends Backbone.View {

    get el() {
      return $(".next-stage")
    }

    initialize() {
      this.$button = this.$(".blue-button")
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "puzzle_sets:next", () => {
        this.$button.attr("href", `/?offset=${blitz.offset}`)
      })
    }

  }


  Views.NextStage = NextStage

}
